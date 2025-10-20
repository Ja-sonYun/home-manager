vim9script

const SCRIPT_DIR = fnamemodify(expand('<script>'), ':p:h')
const LSP_DIR = simplify(SCRIPT_DIR .. '/../lsp')

def ConfigFactoryName(path: string): string
  var name = substitute(fnamemodify(path, ':t:r'), '[^A-Za-z0-9_]', '_', 'g')
  return 'g:LspConfig_' .. name
enddef

def LoadConfig(path: string): dict<any>
  execute 'source ' .. fnameescape(path)
  var factory = ConfigFactoryName(path)
  if exists('*' .. factory)
    return deepcopy(function(factory)())
  endif
  echomsg '[LSP] missing function: ' .. factory .. ' for ' .. path
  return {}
enddef

def LoadAllLspConfigs(): list<dict<any>>
  var configs: list<dict<any>> = []
  for path in globpath(LSP_DIR, '*.vim', 0, 1)
    var cfg = LoadConfig(path)
    if !empty(cfg)
      if has_key(cfg, 'path') && type(cfg.path) == v:t_string
        if empty(cfg.path)
          var label = get(cfg, 'name', fnamemodify(path, ':t:r'))
          echomsg printf('[LSP] executable not found for "%s"', label)
          continue
        endif
        if executable(cfg.path) == 0
          var label2 = get(cfg, 'name', fnamemodify(path, ':t:r'))
          echomsg printf('[LSP] executable "%s" for "%s" is not runnable', cfg.path, label2)
          continue
        endif
      endif
      add(configs, cfg)
    endif
  endfor
  return configs
enddef

def LoadLspOptions(): dict<any>
  return {
    # == Full list of options ==
    # aleSupport: false,
    # autoComplete: true,
    # autoHighlight: false,
    # autoHighlightDiags: true,
    # autoPopulateDiags: false,
    # completionMatcher: 'case',
    # completionMatcherValue: 1,
    # diagSignErrorText: 'E>',
    # diagSignHintText: 'H>',
    # diagSignInfoText: 'I>',
    # diagSignWarningText: 'W>',
    # echoSignature: false,
    # hideDisabledCodeActions: false,
    # highlightDiagInline: true,
    # hoverInPreview: false,
    # ignoreMissingServer: false,
    # keepFocusInDiags: true,
    # keepFocusInReferences: true,
    # completionTextEdit: true,
    # diagVirtualTextAlign: 'above',
    # diagVirtualTextWrap: 'default',
    # noNewlineInCompletion: false,
    # omniComplete: null,
    # omniCompleteAllowBare: false,
    # outlineOnRight: false,
    # outlineWinSize: 20,
    # popupBorder: true,
    # popupBorderHighlight: 'Title',
    # popupBorderHighlightPeek: 'Special',
    # popupBorderSignatureHelp: false,
    # popupHighlightSignatureHelp: 'Pmenu',
    # popupHighlight: 'Normal',
    # semanticHighlight: true,
    # showDiagInBalloon: true,
    # showDiagInPopup: true,
    # showDiagOnStatusLine: false,
    # showDiagWithSign: true,
    # showDiagWithVirtualText: false,
    # showInlayHints: false,
    # showSignature: true,
    # snippetSupport: false,
    # ultisnipsSupport: false,
    # useBufferCompletion: false,
    # usePopupInCodeAction: false,
    # useQuickfixForLocations: false,
    # vsnipSupport: false,
    # bufferCompletionTimeout: 100,
    # customCompletionKinds: false,
    # completionKinds: {},
    # filterCompletionDuplicates: false,
    # condensedCompletionMenu: false,
  }
enddef

augroup LspSetup
  autocmd!
  autocmd User LspSetup call LspOptionsSet(LoadLspOptions())
  autocmd User LspSetup call LspAddServer(LoadAllLspConfigs())
augroup END

nnoremap <silent> gd <Cmd>LspGotoDefinition<CR>
nnoremap <silent> go <Cmd>LspShowReferences<CR>
nnoremap <silent> K  <Cmd>LspHover<CR>
nnoremap <silent> J  <Cmd>LspDiagCurrent<CR>
nnoremap <silent> gI <Cmd>LspGotoImpl<CR>
nnoremap <silent> gD <Cmd>LspGotoDeclaration<CR>
nnoremap <silent> grn <Cmd>LspRename<CR>
nnoremap <silent> gca <Cmd>LspCodeAction<CR>
nnoremap <silent> ]d <Cmd>LspDiag next<CR>
nnoremap <silent> [d <Cmd>LspDiag prev<CR>
nnoremap <silent> g== <Cmd>LspFormat<CR>
