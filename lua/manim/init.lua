local M = {}

-- Default config
M.config = {
	manim_path = "manim", -- system manim
	venv_path = nil, -- optional virtualenv
	play_args = { "-pql" }, -- default play args
	export_args = { "-ql" }, -- default export args
}

-- Setup function to override defaults
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

-- Load modules (no circular require issue)
M.check = require("manim.check")
M.get_class = require("manim.get_class")
M.play = require("manim.play")
-- M.export = require("manim.export") -- optional, add later

-- Optional: define user commands here
vim.api.nvim_create_user_command("ManimCheck", function()
	local check = require("manim.check")
	local manim_cmd = check.manim_available(M.config.manim_path, M.config.venv_path)
	if manim_cmd then
		vim.notify("✔ Manim available at: " .. manim_cmd)
	else
		vim.notify("❌ Manim not found!", vim.log.levels.ERROR)
	end
end, {})

vim.api.nvim_create_user_command("ManimPlay", function()
	local check = require("manim.check")
	local play = require("manim.play")

	if check.ensure_python_parser() then
		-- Parser exists, just run
		play.play()
	else
		-- Parser missing, continue automatically when installed
		vim.api.nvim_create_autocmd("User", {
			pattern = "TSInstallFinished",
			once = true,
			callback = function()
				vim.notify("[manim.nvim] Python parser installed. Running ManimPlay...", vim.log.levels.INFO)
				play.play()
			end,
		})
	end
end, {})

vim.api.nvim_create_user_command("ManimExport", function()
	local export = require("manim.export_class")
	export.export()
end, {})

vim.api.nvim_create_user_command("ManimExportProject", function()
	local export = require("manim.export_project")
	export.exportProject()
end, {})

return M
