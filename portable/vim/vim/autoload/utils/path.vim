vim9script

export class Path
  var _path: string

  static def _StripQuotes(s: string): string
    if strlen(s) >= 2
      var first = strcharpart(s, 0, 1)
      var last = strcharpart(s, strlen(s) - 1, 1)
      if (first ==# "'" && last ==# "'") || (first ==# '"' && last ==# '"')
        return strcharpart(s, 1, strlen(s) - 2)
      endif
    endif
    return s
  enddef

  static def _TrimTrailingSlashes(p: string): string
    return strlen(p) > 1 ? substitute(p, '/\+$', '', '') : p
  enddef

  static def _ToPosix(p: string): string
    return substitute(p, '\\', '/', 'g')
  enddef

  static def _Parts(p: string): list<string>
    if p ==# '/'
      return []
    endif
    return split(p[0] ==# '/' ? p[1 :] : p, '/')
  enddef

  static def _Coerce(path: any): string
    var s: string
    if type(path) == v:t_object
      try
        s = path.String()
      catch
        s = string(path)
      endtry
    elseif type(path) == v:t_string
      s = path
    else
      s = string(path)
    endif
    return Path._StripQuotes(trim(s))
  enddef

  def new(path: any)
    this._path = Path._Coerce(path)
  enddef

  static def Cwd(): Path
    return Path.new(getcwd())
  enddef

  static def Home(): Path
    return Path.new(expand('~'))
  enddef

  def Clone(): Path
    return Path.new(this._path)
  enddef

  def String(): string
    return this._path
  enddef

  def AsPosix(): string
    return Path._ToPosix(this._path)
  enddef

  def Absolute(): Path
    var raw = this._path =~# '^/' ? this._path : fnamemodify(this._path, ':p')
    return Path.new(Path._TrimTrailingSlashes(raw))
  enddef

  def Resolve(): Path
    var resolved = resolve(fnamemodify(this._path, ':p'))
    return Path.new(Path._TrimTrailingSlashes(resolved))
  enddef

  def Relative(): Path
    return Path.new(fnamemodify(this._path, ':.'))
  enddef

  def RelativeTo(base: Path): Path
    var t = Path._TrimTrailingSlashes(Path._ToPosix(this.Absolute().String()))
    var b = Path._TrimTrailingSlashes(Path._ToPosix(base.Absolute().String()))

    if t ==# b
      return Path.new('.')
    endif

    if stridx(t, b .. '/') == 0
      return Path.new(t[strlen(b) + 1 :])
    endif

    var tparts = Path._Parts(t)
    var bparts = Path._Parts(b)

    var i = 0
    var n = min([len(tparts), len(bparts)])
    while i < n && tparts[i] ==# bparts[i]
      i += 1
    endwhile

    var upcount = len(bparts) - i
    if upcount < 0
      upcount = 0
    endif
    var up = repeat(['..'], upcount)
    var rest = tparts[i :]

    var parts = up + rest
    var result = Path.new(empty(parts) ? '.' : join(parts, '/'))
    return result
  enddef

  def Parent(): Path
    return Path.new(fnamemodify(this._path, ':h'))
  enddef

  def Name(): string
    return fnamemodify(this._path, ':t')
  enddef

  def Stem(): string
    return fnamemodify(this._path, ':t:r')
  enddef

  def Suffix(): string
    return fnamemodify(this._path, ':e')
  enddef

  def WithName(name: string): Path
    return Path.new(fnamemodify(this._path, ':h') .. '/' .. name)
  enddef

  def WithSuffix(sfx: string): Path
    var base = fnamemodify(this._path, ':r')
    return Path.new(base .. (sfx ==# '' ? '' : '.' .. sfx))
  enddef

  def Join(parts: any): Path
    if type(parts) == v:t_list
      var p = this._path
      for s in parts
        var seg = string(s)
        p = p .. (p =~# '/$' ? '' : '/') .. seg
      endfor
      return Path.new(p)
    else
      var s2 = string(parts)
      var sep = this._path =~# '/$' ? '' : '/'
      return Path.new(this._path .. sep .. s2)
    endif
  enddef

  def Exists(): bool
    return filereadable(this._path) || isdirectory(this._path)
  enddef

  def IsFile(): bool
    return filereadable(this._path)
  enddef

  def IsDir(): bool
    return isdirectory(this._path)
  enddef

  def Touch(): void
    if !filereadable(this._path)
      writefile([], this._path)
    else
      writefile(readfile(this._path), this._path)
    endif
  enddef

  def Mkdir(parents: bool = false): void
    mkdir(this._path, parents ? 'p' : '')
  enddef

  def Remove(): void
    delete(this._path)
  enddef

  def Rmdir(): void
    delete(this._path, 'd')
  enddef

  def Rename(to: any): void
    var dst = Path._Coerce(to)

    if this._path ==# dst
      return
    endif
    if filereadable(dst) || isdirectory(dst)
      delete(dst, 'rf')
    endif
    if rename(this._path, dst) != 0
      throw 'rename failed'
    endif
    this._path = dst
  enddef

  def ReadText(): string
    return join(readfile(this._path), "\n")
  enddef

  def WriteText(text: string): void
    writefile(split(text, '\n', 1), this._path)
  enddef

  def AppendText(text: string): void
    writefile(split(text, '\n', 1), this._path, 'a')
  enddef

  def ReadLines(): list<string>
    return readfile(this._path)
  enddef

  def WriteLines(lines: list<string>): void
    if len(lines) == 1 && lines[0] ==# ''
      writefile([], this._path)
    else
      writefile(lines, this._path)
    endif
  enddef

  def AppendLines(lines: list<string>): void
    if !empty(lines)
      writefile(lines, this._path, 'a')
    endif
  enddef

  def Iterdir(): list<Path>
    if !isdirectory(this._path)
      return []
    endif
    var pat = this._path .. (this._path =~# '/$' ? '*' : '/*')
    var entries = glob(pat, 0, 1)
    return map(
          filter(entries, (_, v) => fnamemodify(v, ':t') !=# '.' && fnamemodify(v, ':t') !=# '..'),
          (_, v) => Path.new(v))
  enddef

  def Glob(pattern: string): list<Path>
    return map(globpath(this._path, pattern, 0, 1), (_, v) => Path.new(v))
  enddef

  def Stat(): dict<any>
    return {
      path: this._path,
      size: getfsize(this._path),
      mtime: getftime(this._path),
      perm: getfperm(this._path),
      type: getftype(this._path),
      readable: filereadable(this._path) ? 1 : 0,
      isdir: isdirectory(this._path) ? 1 : 0,
    }
  enddef

  def Chmod(mode: string): void
    setfperm(this._path, mode)
  enddef

  static def From(parts: list<string>): Path
    if empty(parts)
      return Path.new('')
    endif
    return Path.new(join(parts, '/'))
  enddef

  static def Temp(suffix: string = ''): Path
    var base = tempname()
    var addsuffix = suffix !=# '' ? '.' .. suffix : ''
    var tmp = Path.new(base .. addsuffix)
    return tmp
  enddef
endclass
