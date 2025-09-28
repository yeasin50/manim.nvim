-- play_from.lua
local M = {}
local check = require("manim.check")
local get_class = require("manim.get_class")

-- Prepare temporary file with injected lines
local function prepare_temp_file(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local modified = {}
	local construct_line = nil
	local construct_indent = ""

	-- Find construct() and copy lines
	for i, line in ipairs(lines) do
		table.insert(modified, line)
		if line:match("^%s*def construct%(") then
			construct_line = i
			construct_indent = line:match("^(%s*)") or ""
			-- Inject skip_animations line immediately after construct()
			table.insert(
				modified,
				construct_line + 1,
				construct_indent .. "    self.next_section(skip_animations=True)"
			)
		end
	end

	-- Inject self.next_section() at cursor line
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1] or construct_line + 2
	cursor_line = math.min(cursor_line, #modified)
	table.insert(modified, cursor_line, construct_indent .. "    self.next_section()")

	-- Write temp file
	local cwd = vim.fn.getcwd()
	local tmpfile = cwd .. "/.manim_play.py"
	vim.fn.writefile(modified, tmpfile)
	return tmpfile
end

-- Main function
function M.playFrom(bufnr, extra_args)
	bufnr = bufnr or 0
	local config = require("manim").config

	local manim_cmd = check.manim_available(config.manim_path, config.venv_path)
	if not manim_cmd then
		vim.notify("❌ Manim not found!", vim.log.levels.ERROR)
		return
	end

	local class_name = get_class.get_class(bufnr)
	if not class_name then
		vim.notify("⚠ Cursor not inside a class", vim.log.levels.WARN)
		return
	end

	if not get_class.has_manim_import(bufnr) then
		vim.notify("⚠ No `import manim` found in this file", vim.log.levels.WARN)
		return
	end

	local tmpfile = prepare_temp_file(bufnr)
	local args = vim.tbl_flatten({ config.play_args, extra_args or {} })
	local cmd_str = string.format("%s %s %s %s\n", manim_cmd, table.concat(args, " "), tmpfile, class_name)

	-- Send command to first terminal buffer
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_option(b, "buftype") == "terminal" then
			local chan = vim.b[b].terminal_job_id
			if chan then
				vim.api.nvim_chan_send(chan, cmd_str)
				vim.notify("▶ Sent Manim command to terminal (temp file): " .. class_name)
				return
			end
		end
	end

	vim.notify("❌ No terminal open (<C-\\>)", vim.log.levels.ERROR)
end

return M
