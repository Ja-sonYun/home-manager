if require("modules.plugin").mark_as_loaded("autocmds") then
	return
end

-----------------------------------------------------------
-- Highlight on yank
-----------------------------------------------------------
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = "1000" })
	end,
})

-----------------------------------------------------------
-- Don't auto commenting new lines
-----------------------------------------------------------
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "",
	command = "set fo-=c fo-=r fo-=o",
})

-----------------------------------------------------------
-- Remove whitespace on save
-----------------------------------------------------------
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "",
	callback = function()
		if not vim.b.is_code then
			return
		end
		vim.cmd(":%s/\\s\\+$//e")
	end,
})

-----------------------------------------------------------
-- Switch Rel - Abs number
-----------------------------------------------------------
local modifyRelativeNumber = vim.api.nvim_create_augroup("ModifyRelativeNumber", { clear = true })
for _, event in ipairs({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave", "CmdlineEnter" }) do
	vim.api.nvim_create_autocmd(event, {
		group = modifyRelativeNumber,
		callback = function()
			if not vim.b.is_code then
				return
			end

			vim.opt_local.relativenumber = false
		end,
	})
end

for _, event in ipairs({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter", "CmdlineLeave" }) do
	vim.api.nvim_create_autocmd(event, {
		group = modifyRelativeNumber,
		callback = function()
			if not vim.b.is_code then
				return
			end

			vim.opt_local.number = true
			vim.opt_local.relativenumber = true
		end,
	})
end

-----------------------------------------------------------
-- Open file at the last position it was edited earlier
-----------------------------------------------------------
vim.api.nvim_create_autocmd("BufReadPost", {
	desc = "Open file at the last position it was edited earlier",
	group = vim.api.nvim_create_augroup("OpenFileAtLastPosition", { clear = true }),
	pattern = "*",
	command = 'silent! normal! g`"zv',
})

-----------------------------------------------------------
-- Dynamic on save callback
-- Usage:
--   export VIM_ON_SAVE_HOOK="echo 'File saved'"
--   export VIM_ON_SAVE_HOOK="black %"  # Format current file with black
--   export VIM_ON_SAVE_HOOK="make test"  # Run tests on save
--
-- Optional file pattern matching:
--   export VIM_ON_SAVE_HOOK_TRIGGER_RULES="*.py,*.js"  # Only trigger on Python/JS files
--   export VIM_ON_SAVE_HOOK_TRIGGER_RULES="*.py"       # Only trigger on Python files
-----------------------------------------------------------
local function is_file_in_glob(pattern, filename)
	local patterns = vim.split(pattern, ",")
	for _, pat in ipairs(patterns) do
		local files = vim.fn.glob(pat, false, true)
		for _, file in ipairs(files) do
			if file == filename then
				return true
			end
		end
	end
	return false
end

vim.api.nvim_create_autocmd("BufWritePost", {
	group = vim.api.nvim_create_augroup("OnSaveHook", { clear = true }),
	pattern = "*",
	callback = function()
		-- Check if VIM_ON_SAVE_HOOK environment variable is set
		if vim.env.VIM_ON_SAVE_HOOK then
			-- If VIM_ON_SAVE_HOOK_TRIGGER_RULES is not set, run on all files
			if vim.env.VIM_ON_SAVE_HOOK_TRIGGER_RULES == nil then
				vim.fn.system(vim.env.VIM_ON_SAVE_HOOK)
			else
				-- Check if current file matches the trigger rules pattern
				local file_hit = is_file_in_glob(vim.env.VIM_ON_SAVE_HOOK_TRIGGER_RULES, vim.fn.expand("%:t"))
				if file_hit then
					vim.fn.system(vim.env.VIM_ON_SAVE_HOOK)
				end
			end
		end
	end,
})
