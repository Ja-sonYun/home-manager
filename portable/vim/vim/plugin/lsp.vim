vim9script

const S_DIR   = fnamemodify(expand('<script>'), ':p:h')
const LSP_DIR = simplify(S_DIR .. '/../lsp')

def LoadAllLspConfigs(): list<dict<any>>
  const files = globpath(LSP_DIR, '*.vim', 0, 1)
  var cfgs: list<dict<any>> = []
  for f in files
    execute('source ' .. fnameescape(f))
    var name = fnamemodify(f, ':t:r')
    name = substitute(name, '[^A-Za-z0-9_]', '_', 'g')
    var F = 'g:LspConfig_' .. name
    if exists('*' .. F)
      add(cfgs, deepcopy(call(function(F), [])))
    else
      echomsg '[LSP] missing function: ' .. F .. ' for ' .. f
    endif
  endfor
  return cfgs
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

autocmd User LspSetup call LspOptionsSet(LoadLspOptions())
autocmd User LspSetup call LspAddServer(LoadAllLspConfigs())

nnoremap <silent> gd <Cmd>LspGotoDefinition<CR>
nnoremap <silent> go <Cmd>LspShowReferences<CR>
nnoremap <silent> K  <Cmd>LspHover<CR>
nnoremap <silent> gi <Cmd>LspGotoImpl<CR>
nnoremap <silent> gD <Cmd>LspGotoDeclaration<CR>
nnoremap <silent> grn <Cmd>LspRename<CR>
nnoremap <silent> gca <Cmd>LspCodeAction<CR>
nnoremap <silent> ]d <Cmd>LspDiag next<CR>
nnoremap <silent> [d <Cmd>LspDiag prev<CR>
nnoremap <silent> == <Cmd>LspFormat<CR>
