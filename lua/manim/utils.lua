local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")

function M.get_class_under_cursor(bufnr)
	bufnr = bufnr or 0
	local node = ts_utils.get_node_at_cursor()
	while node do
		if node:type() == "class_definition" then
			local name_node = node:field("name")[1]
			if name_node then
				return vim.treesitter.get_node_text(name_node, bufnr)
			end
		end
		node = node:parent()
	end
	return nil
end

function M.has_manim_import(bufnr)
	bufnr = bufnr or 0
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for _, line in ipairs(lines) do
		if line:match("^%s*import%s+manim") or line:match("^%s*from%s+manim") then
			return true
		end
	end
	return false
end

return M
