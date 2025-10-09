-- ----- format -----
local SEP = " | "
local sep_pat = vim.pesc(SEP) -- literal match

local function relpath(bufnr)
	local p = vim.fn.bufname(bufnr)
	return vim.fn.fnamemodify(p, ":~:.")
end

-- Read a single line from buffer or file
local function get_line(bufnr, lnum)
	if bufnr > 0 and vim.api.nvim_buf_is_loaded(bufnr) then
		local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, lnum - 1, lnum, false)
		if ok and lines and lines[1] then
			return lines[1]
		end
	end
	local path = vim.fn.bufname(bufnr)
	if path ~= "" and vim.fn.filereadable(path) == 1 then
		local ok, lines = pcall(vim.fn.readfile, path, "", lnum) -- reads first lnum lines
		if ok and lines and lines[lnum] then
			return lines[lnum]
		end
	end
	return ""
end

local function truncate(s, max)
	if #s <= max then
		return s
	end
	return s:sub(1, max)
end

local function norm(s)
	return (s or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

_G.QfText = function(info)
	-- fetch all items once
	local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
	local out = {}
	for i = info.start_idx, info.end_idx do
		local it = items[i]
		if not it then
			break
		end

		local file = relpath(it.bufnr)
		local lnum = it.lnum or 0
		local code = get_line(it.bufnr, lnum):gsub("\t", "  ")
		local msg = it.text or ""

		code = truncate(code, 120)

		local show_msg = norm(msg) ~= "" and norm(msg) ~= norm(code)

		if show_msg then
			table.insert(out, string.format("%-35s%s%6d%s %s%s %s", file, SEP, lnum, SEP, code, SEP, msg))
		else
			table.insert(out, string.format("%-35s%s%6d%s %s", file, SEP, lnum, SEP, code))
		end
	end
	return out
end

vim.o.quickfixtextfunc = "v:lua.QfText"

-- ----- highlight -----
local ns = vim.api.nvim_create_namespace("qf_hl")

-- Apply per-column highlights using byte indices
local function apply_qf_hl(buf)
	if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "qf" then
		return
	end
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for row, l in ipairs(lines) do
		local s1a, s1b = l:find(sep_pat, 1, false) -- 1-based inclusive
		if s1a then
			local s2a, s2b = l:find(sep_pat, s1b + 1, false)
			if s2a then
				local s3a, s3b = l:find(sep_pat, s2b + 1, false)
				-- file [0 .. s1a-1)
				vim.api.nvim_buf_add_highlight(buf, ns, "Directory", row - 1, 0, s1a - 1)
				-- lnum [s1b .. s2a-1)
				vim.api.nvim_buf_add_highlight(buf, ns, "LineNr", row - 1, s1b, s2a - 1)
				if s3a then
					-- code [s2b .. s3a-1)
					vim.api.nvim_buf_add_highlight(buf, ns, "NormalNC", row - 1, s2b, s3a - 1)
					-- msg [s3b .. end)
					vim.api.nvim_buf_add_highlight(buf, ns, "DiagnosticWarn", row - 1, s3b, -1)
				else
					-- code only [s2b .. end)
					vim.api.nvim_buf_add_highlight(buf, ns, "NormalNC", row - 1, s2b, -1)
				end
			end
		end
	end
end

-- ----- window opts -----
local function set_winopts_for_buf(buf)
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		vim.api.nvim_set_option_value("wrap", false, { win = win })
		vim.api.nvim_set_option_value("number", false, { win = win })
		vim.api.nvim_set_option_value("relativenumber", false, { win = win })
		vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
		vim.api.nvim_set_option_value("foldcolumn", "0", { win = win })
	end
end

-- ----- autocmds -----
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function(args)
		vim.bo[args.buf].modifiable = false
		vim.bo[args.buf].swapfile = false
		set_winopts_for_buf(args.buf)
		vim.schedule(function()
			apply_qf_hl(args.buf)
		end)
	end,
})

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	pattern = { "[^l]*", "l*" },
	callback = function()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].filetype == "qf" then
				set_winopts_for_buf(buf)
				vim.schedule(function()
					apply_qf_hl(buf)
				end)
			end
		end
	end,
})
