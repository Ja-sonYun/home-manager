vim9script

export class Spec
  var kind: string
  var text: string = ''
  var texthl: string = ''
  var numhl: string = ''
  var linehl: string = ''

  def Define(group: string): void
    var d: dict<any> = {}
    if this.text !=# ''
      d.text = this.text
    endif
    if this.texthl !=# ''
      d.texthl = this.texthl
    endif
    if this.numhl !=# ''
      d.numhl = this.numhl
    endif
    if this.linehl !=# ''
      d.linehl = this.linehl
    endif
    sign_define(group .. '_' .. this.kind, d)
  enddef
endclass

export class Item
  var kind: string
  var lnum: number
  var key: string = ''

  def Key(): string
    if this.key !=# ''
      return this.key
    endif
    return this.kind .. '@' .. string(this.lnum)
  enddef
endclass

class Placed
  var id: number
  public var lnum: number
  public var kind: string

  def new(this.id, this.lnum, this.kind)
  enddef

  def Unplace(group: string, buf: number): void
    sign_unplace(group, { buffer: buf, id: this.id })
  enddef
endclass

class State
  public var placed: dict<Placed> = {}

  def Clear(group: string, buf: number): void
    if empty(this.placed)
      return
    endif
    sign_unplace(group, { buffer: buf })
    this.placed = {}
  enddef
endclass

export class SignCol
  static var spec_hash: dict<string> = {}

  public var group: string
  public var kinds: dict<Spec> = {}
  public var state: dict<State> = {}

  def new(this.group, specs: list<Spec>)
    for spec in specs
      this.kinds[spec.kind] = spec
    endfor
    this.DefineKindsIfChanged()
  enddef

  def NameFor(kind: string): string
    return this.group .. '_' .. kind
  enddef

  def DefineKindsIfChanged()
    var sig = string(map(copy(this.kinds), (_, v) => [v.kind, v.text, v.texthl, v.numhl, v.linehl]))
    var h = sha256(sig)
    if get(SignCol.spec_hash, this.group, '') ==# h
      return
    endif
    for [_, sp] in items(this.kinds)
      sp.Define(this.group)
    endfor
    SignCol.spec_hash[this.group] = h
  enddef

  def GetState(buf: number): State
    var sb = string(buf)
    if has_key(this.state, sb)
      return this.state[sb]
    endif
    var st = State.new()
    this.state[sb] = st
    return st
  enddef

  def ClampLnum(buf: number, l: number): number
    var info = get(getbufinfo(buf), 0, {})
    var maxln = get(info, 'linecount', 0)
    if maxln <= 0
      return l
    endif
    if l < 1
      return 1
    endif
    if l > maxln
      return maxln
    endif
    return l
  enddef

  def Update(buf: number, entries: list<Item>): void
    if buf <= 0
      return
    endif

    var sb = string(buf)
    var st: State = this.GetState(buf)
    var placed: dict<Placed> = st.placed

    var info = get(getbufinfo(buf), 0, {})
    var maxln = get(info, 'linecount', 0)
    if maxln <= 0
      return
    endif

    var want: dict<dict<any>> = {}
    for it in entries
      if type(it) != v:t_object
        continue
      endif
      if !has_key(this.kinds, it.kind)
        continue
      endif
      var l = this.ClampLnum(buf, it.lnum)
      want[it.Key()] = { kind: it.kind, lnum: l }
    endfor

    var keep_ids: dict<number> = {}
    for [k, pl] in items(placed)
      if has_key(want, k)
        var tgt = want[k]
        if pl.lnum == tgt.lnum && pl.kind ==# tgt.kind
          keep_ids[pl.id] = 1
          remove(want, k)
        endif
      endif
    endfor

    var cur = sign_getplaced(buf, { group: this.group })
    if !empty(cur) && has_key(cur[0], 'signs')
      for s in cur[0].signs
        var cid = get(s, 'id', 0)
        if cid > 0 && !has_key(keep_ids, cid)
          sign_unplace(this.group, { buffer: buf, id: cid })
        endif
      endfor
    endif

    if !empty(cur) && has_key(cur[0], 'signs')
      var live: dict<number> = {}
      for s in cur[0].signs
        var cid = get(s, 'id', 0)
        if cid > 0
          live[cid] = 1
        endif
      endfor
      for [k2, pl2] in items(placed)
        if !has_key(live, pl2.id)
          remove(placed, k2)
        else
          var ln = filter(copy(cur[0].signs), (_, x) => get(x, 'id', 0) == pl2.id)
          if !empty(ln)
            placed[k2].lnum = get(ln[0], 'lnum', pl2.lnum)
          endif
        endif
      endfor
    else
      placed = {}
    endif

    if !empty(want)
      var add_list: list<dict<any>> = []
      var add_keys: list<string> = []
      for [k3, v3] in items(want)
        add(add_list, {
          buffer: buf,
          group: this.group,
          id: 0,
          name: this.NameFor(v3.kind),
          lnum: v3.lnum,
        })
        add(add_keys, k3)
      endfor
      var ids: list<number> = sign_placelist(add_list)
      for i in range(0, len(ids) - 1)
        if ids[i] > 0
          var kk = add_keys[i]
          var idn = ids[i]
          var kind = substitute(add_list[i].name, '^' .. this.group .. '_', '', '')
          placed[kk] = Placed.new(idn, add_list[i].lnum, kind)
        endif
      endfor
    endif

    st.placed = placed
    this.state[sb] = st
  enddef


  def Clear(buf: number): void
    var sb = string(buf)
    if has_key(this.state, sb)
      this.state[sb].Clear(this.group, buf)
    endif
  enddef

  def ClearAll(): void
    for [b, st] in items(this.state)
      st.Clear(this.group, str2nr(b))
    endfor
  enddef

  def Status(buf: number): dict<any>
    var count = 0
    var sb = string(buf)
    if has_key(this.state, sb)
      count = len(keys(this.state[sb].placed))
    endif
    return { buffer: buf, placed: count, group: this.group }
  enddef
endclass
