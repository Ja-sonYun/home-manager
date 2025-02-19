if require('modules.plugin').mark_as_loaded('conform') then
  return
end

local util = require('conform.util')
util.add_formatter_args(require('conform.formatters.shfmt'), { '-i', '2' })

vim.schedule(function()
  require('conform').setup {
    notify_on_error = false,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'pysen', 'my_isort', 'my_black' }, --, "ruff_fix" },
      terraform = { 'terraform_fmt' },
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      json = { 'prettierd', 'prettier', stop_after_first = true },
      go = { 'gofmt' },
      html = { 'prettierd', 'prettier', stop_after_first = true },
      css = { 'prettierd', 'prettier', stop_after_first = true },
      rust = { 'rustfmt' },
      swift = { 'swiftformat' },
      sh = { 'shellscript', 'shellcheck' },
      bash = { 'shellscript', 'shellcheck' },
      zsh = { 'shellscript', 'shellcheck' },
      markdown = { 'markdownlint' },
      c = { 'clang_format' },
      cpp = { 'clang_format' },
      nix = { 'nixpkgs_fmt' },

      ['_'] = { 'trim_whitespace' },
    },
    -- format_on_save = { timeout_ms = 500, lsp_fallback = true },
    formatters = {
      rustfmt = {
        command = 'rustfmt',
        args = { '--edition', '2021' },
      },
      shellscript = {
        command = 'shfmt',
        args = { '-i', '4', '-ci' },
      },
      -- swift
      swiftformat = {
        command = 'swift-format',
        args = { '$FILENAME', '-i' },
        stdin = false,
      },
      -- Python formatters
      pysen = {
        command = 'poetry',
        args = { 'run', 'pysen', 'run_files', 'format', '$FILENAME' },
        stdin = false,
        condition = function(self, ctx)
          local pyproject = vim.fn.system('cat pyproject.toml')
          return string.find(pyproject, 'pysen')
        end,
        exit_codes = { 0 },
        env = {
          PYSEN_IGNORE_GIT = 1,
        },
      },
      my_isort = {
        command = 'isort',
        args = { '$FILENAME' },
        condition = function(self, ctx)
          local pysen = vim.fn.system('[ -f pyproject.toml ] && cat pyproject.toml')
          return not string.find(pysen, 'pysen')
        end,
        stdin = false,
        exit_codes = { 0 },
      },
      my_black = {
        command = 'black',
        args = { '$FILENAME' },
        condition = function(self, ctx)
          local pysen = vim.fn.system('[ -f pyproject.toml ] && cat pyproject.toml')
          return not string.find(pysen, 'pysen')
        end,
        stdin = false,
        exit_codes = { 0 },
      },
      nixpkgs_fmt = {
        command = 'nixpkgs-fmt',
        args = { '$FILENAME' },
        stdin = false,
        exit_codes = { 0 },
      },
    },
  }
  vim.keymap.set('n', 'ql', function()
    vim.notify('Formatting...')
    require('conform').format({ async = true, lsp_fallback = true }, function(err)
      if err then
        vim.notify('Failed to format', vim.log.levels.ERROR)
      else
        vim.notify('Format successful')
      end
    end)
  end)

  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
end)
