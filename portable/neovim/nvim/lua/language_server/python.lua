local M = {}

M._registered_python_paths = {}

--- Get the path to the Python executable.
--- @param workspace string|nil
--- @return string
--- @return string|nil
M.get_python_path = function(workspace)
  local Path = require('plenary.path')
  local current_folder = workspace or vim.fn.expand('%:p:h')

  local founded_keys = require('modules.table').keys(M._registered_python_paths)
  table.sort(founded_keys, function(a, b)
    return #a > #b
  end)
  for _, key in ipairs(founded_keys) do
    if current_folder:find(key, 1, true) then
      vim.notify('Using registered Python path', vim.log.levels.INFO)
      local venv_path, venv_dir = unpack(M._registered_python_paths[key])
      return venv_path, venv_dir
    end
  end

  local home = os.getenv('HOME')

  while current_folder do
    if current_folder == home then
      break
    end -- If only root remains, exit

    -- if .pyvenv.cfg exists, use it. it will include absolute path to venv
    local venv_cfg = Path:new(current_folder, '.pyvenv')
    if venv_cfg:exists() then
      local venv_path = Path:new(venv_cfg:readlines()[1]):absolute()
      vim.notify('Using venv: ' .. venv_path, vim.log.levels.INFO)
      M._registered_python_paths[current_folder] = { venv_path, current_folder }
      return venv_path, current_folder
    end

    -- Find and use virtualenv in workspace directory.
    -- Search for parent dir, sometimes vim-rooter use src folder
    for _, pattern in ipairs { '.venv' } do
      local pyvenv_flag = Path:new(current_folder, pattern, 'pyvenv.cfg')
      if pyvenv_flag:exists() then
        local venv_path = Path:new(current_folder, pattern, 'bin', 'python3'):absolute()
        vim.notify('Using venv: ' .. venv_path, vim.log.levels.INFO)
        M._registered_python_paths[current_folder] = { venv_path, current_folder }
        return venv_path, current_folder
      end
    end
    -- Remove the last '/segment'
    local new = current_folder:match('(.+)/[^/]+$')
    current_folder = new
  end

  local venv_env_path = os.getenv('VIRTUAL_ENV')
  -- Use activated virtualenv.
  if venv_env_path then
    -- Join paths using Plenary's Path:new(...)
    local venv_path = Path:new(venv_env_path, 'bin', 'python3'):absolute()
    vim.notify('Using venv: ' .. venv_path, vim.log.levels.INFO)
    M._registered_python_paths[venv_env_path] = { venv_path, venv_env_path }
    return venv_path, venv_env_path
  end

  -- Fallback to system Python.
  vim.notify('Using system Python', vim.log.levels.INFO)
  return vim.g.python3_host_prog, nil
end

--- Start the Pyright language server.
--- @param python_path string
--- @return nil
M.pyright = function(python_path)
  if vim.fn.executable('pyright') then
    local root_files = {
      'flake.nix',
      'default.nix',
      'shell.nix',
      'pyproject.toml',
      'setup.py',
      'requirements.txt',
      'poetry.lock',
      '.git',
      '.gitignore',
      '.gitmodules',
      '.venv',
    }

    -- TODO: Remove the oldest client if there are more than 4 clients
    -- if M._running_pyright == nil then
    --   M._running_pyright = {}
    -- else
    --   -- If pyright is running more than 4 clients, remove the oldest one
    --   if #M._running_pyright > 4 then
    --     vim.lsp.stop_client(M._running_pyright:remove(1))
    --     vim.notify('Stopped Pyright client since there are too many clients')
    --   end
    -- end

    local client_id = vim.lsp.start {
      name = 'pyright',
      cmd = { 'pyright-langserver', '--stdio' },
      root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
      capabilities = require('modules.lsp').make_client_capabilities(),
      settings = {
        python = {
          inlayHints = {
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = true,
          },
        },
      },
      before_init = function(_, config)
        vim.notify('Starting Pyright', vim.log.levels.INFO)
        config.settings.python.pythonPath = python_path
      end,
    }
    -- if client_id then
    --   M._running_pyright:insert(client_id)
    -- end
  else
    vim.notify('pyright not found', vim.log.levels.ERROR)
  end
end

return M
