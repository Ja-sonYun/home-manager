-----------------------------------------------------------
-- Macro
-----------------------------------------------------------
-- unset q and @ mapping
vim.keymap.set("n", "q", "<Nop>", { desc = "No operation" })
vim.keymap.set("n", "@", "<Nop>", { desc = "No operation" })
--
vim.keymap.set("n", "@@", "q", { desc = "Start recording macro" })
vim.keymap.set("n", "qq", "@", { desc = "Execute macro" })
-- vim.keymap.set("n", "q", "@@", { desc = "Repeat last macro" })
vim.keymap.set("n", "Q", ":MacroList<CR>:MacroEdit<CR>", { desc = "Edit macro" })

vim.cmd([[
  function! YankToRegister()
    " Remove trailing whitespace and newlines
    silent! %s/\n\+/\r/g
    exe printf('norm! ^"%sy$', b:register_name)
    echo "Macro saved to register " . b:register_name
  endfunction

  function! OpenMacroEditorWindow()
    let register_name = nr2char(getchar())

    " Check if the register name is valid
    if register_name !~# '[a-zA-Z0-9"]'
      echohl ErrorMsg
      echom "Invalid register: " . register_name
      echohl None
      return
    endif

    let bufname = 'MacroEditor[' . register_name . ']'

    " If the buffer already exists, switch to it
    if bufexists(bufname)
      let win = bufwinnr(bufname)
      exe win . 'wincmd w'
      return
    endif

    " Create a new buffer for macro editing
    execute 'botright 5new ' . bufname
    let b:register_name = register_name

    " Set buffer options
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal nobuflisted
    setlocal buftype=acwrite
    setlocal filetype=vim
    setlocal nowrap

    " Load the macro content from the register
    let macro_content = getreg(b:register_name)
    if !empty(macro_content)
      " Convert the macro content to a readable format
      let readable = substitute(macro_content, '\n', '\\n', 'g')
      let readable = substitute(readable, '\r', '\\r', 'g')
      let readable = substitute(readable, '\t', '\\t', 'g')
      let readable = substitute(readable, '\e', '\\e', 'g')
      put =readable
      normal! ggdd
    endif

    " Set buffer options for macro editing
    setlocal statusline=MacroEditor\ [%{b:register_name}]\ %m

    " Create an autocommand group for macro editing
    augroup MacroEditor
      au! * <buffer>
      au BufWriteCmd <buffer> call SaveMacro()
      au BufWinLeave <buffer> call CleanupMacro()
    augroup END
  endfunction

  function! SaveMacro()
    " Save the macro content to the register
    let content = join(getline(1, '$'), '')
    let content = substitute(content, '\\n', '\n', 'g')
    let content = substitute(content, '\\r', '\r', 'g')
    let content = substitute(content, '\\t', '\t', 'g')
    let content = substitute(content, '\\e', '\e', 'g')

    call setreg(b:register_name, content)
    setlocal nomodified
    echo "Macro saved to register " . b:register_name
  endfunction

  function! CleanupMacro()
    if exists('#MacroEditor')
      au! MacroEditor * <buffer>
    endif
  endfunction

  " List all macros in registers a-z
  function! ListMacros()
    let registers = 'abcdefghijklmnopqrstuvwxyz'
    echo "Registered macros:"
    echo "=================="
    for r in split(registers, '\zs')
      let content = getreg(r)
      if !empty(content)
        let preview = strpart(substitute(content, '\n', '\\n', 'g'), 0, 50)
        if len(content) > 50
          let preview .= '...'
        endif
        echo printf("%s: %s", r, preview)
      endif
    endfor
  endfunction

  command! MacroEdit call OpenMacroEditorWindow()
  command! MacroList call ListMacros()
]])
