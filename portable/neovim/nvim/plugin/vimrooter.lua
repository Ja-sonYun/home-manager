if require("modules.plugin").mark_as_loaded("vim_rooter") then
	return
end

vim.g.rooter_patterns = require("modules.constant").root_markers
