-- export_project.lua
local M = {}

function M.exportProject()
	local config = require("manim").config
	local proj_conf = config.project_config or {}

	local plugin_path = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
	local python_script = plugin_path .. "export_project.py"

	if vim.fn.filereadable(python_script) == 0 then
		vim.notify("❌ Python export script not found: " .. python_script, vim.log.levels.ERROR)
		return
	end

	local manim_cmd = require("manim.check").manim_available(config.manim_path, config.venv_path)
	if not manim_cmd then
		vim.notify("❌ Manim not found!", vim.log.levels.ERROR)
		return
	end

	local env_cmd = string.format(
		"MANIM_CMD='%s' RESOLUTION_X=%d RESOLUTION_Y=%d FPS=%d TRANSPARENT=%d EXPORT_DIR='%s' MAX_WORKERS=%d IGNORE_FILES='%s' FAILED_LIST_FILE='%s'",
		manim_cmd,
		(proj_conf.resolution and proj_conf.resolution[1]) or 3840,
		(proj_conf.resolution and proj_conf.resolution[2]) or 2160,
		proj_conf.fps or 60,
		proj_conf.transparent and 1 or 0,
		proj_conf.export_dir or "./outputs",
		proj_conf.max_workers or 1,
		table.concat(proj_conf.ignore_files or {}, ","),
		proj_conf.failed_list_file or "failed_files.txt"
	)

	local cmd_str = string.format("%s python3 %s", env_cmd, python_script)

	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_option(b, "buftype") == "terminal" then
			local chan = vim.b[b].terminal_job_id
			if chan then
				vim.api.nvim_chan_send(chan, cmd_str .. "\n")
				vim.notify("▶ Sent Python export command to terminal")
				return
			end
		end
	end

	vim.notify("❌ No terminal open (<C-\\>)", vim.log.levels.ERROR)
end

return M
