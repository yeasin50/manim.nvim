-- export_class.lua
local M = {}
local check = require("manim.check")
local get_class = require("manim.get_class")

-- when  user wanna move exported files
local function append_export_dest(cmd, config, class_name)
	if not config.export_file_dest then
		return cmd
	end

	local media_dir
	for _, arg in ipairs(config.export_args) do
		media_dir = arg:match("^%-%-media_dir=(.+)$")
		if media_dir then
			break
		end
	end

	if media_dir then
		cmd = cmd
			.. string.format(
				" && mv \"$(find '%s/videos' -name '%s.*')\" '%s/' && echo '\n📁 %s/'",
				media_dir,
				class_name,
				config.export_file_dest,
				config.export_file_dest
			)
	end

	return cmd
end

function M.export(bufnr, extra_args)
	local config = require("manim").config
	bufnr = bufnr or 0

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

	if not get_class.has_manim_import(bufnr) then -- thinking about switching to Scene(extend)
		vim.notify("⚠ No `import manim` found in this file", vim.log.levels.WARN)
		return
	end

	local file = vim.api.nvim_buf_get_name(bufnr)
	local args = vim.tbl_flatten({ config.export_args, extra_args or {} })
	local cmd_str = string.format("%s %s %s %s", manim_cmd, table.concat(args, " "), file, class_name)
	cmd_str = append_export_dest(cmd_str, config, class_name)

	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_option(b, "buftype") == "terminal" then
			local chan = vim.b[b].terminal_job_id
			if chan then
				vim.api.nvim_chan_send(chan, cmd_str .. "\n")
				vim.notify("▶ Sent Manim export command to terminal: " .. class_name)
				return
			end
		end
	end

	vim.notify("❌ No terminal open (<C-\\>)", vim.log.levels.ERROR)
end

return M
