vim.opt.exrc = true
vim.opt.secure = true

local workspace_path = vim.fn.getcwd()
local cache_dir = vim.fn.stdpath("data")
local unique_id = vim.fn.fnamemodify(workspace_path, ":t") .. "_" .. vim.fn.sha256(workspace_path):sub(1, 8)
local shadafile = cache_dir .. "/myshada/" .. unique_id .. ".shada"

vim.fn.mkdir(cache_dir .. "/myshada", "p")
vim.opt.shadafile = shadafile
