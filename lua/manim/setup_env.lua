local M = {}

local function get_python()
	local python = vim.fn.exepath("python3")

	if python == "" then
		python = vim.fn.exepath("python")
	end

	if python == "" then
		return nil, "Python not found"
	end

	local version = vim.fn.system({ python, "-c", "import sys; print(sys.version_info.major)" })

	if vim.v.shell_error ~= 0 or vim.trim(version) ~= "3" then
		return nil, "Python 3 is required"
	end

	return python
end

local config = require("manim").config

local function get_venv_path()
	if not config or not config.venv_path or config.venv_path == "" then
		return nil, "venv_path is not configured in setup()"
	end

	return config.venv_path
end

function M.install()
	local python, perr = get_python()
	if not python then
		vim.notify("❌ " .. perr, vim.log.levels.ERROR)
		return
	end

	local venv_dir, verr = get_venv_path()
	if not venv_dir then
		vim.notify("❌ " .. verr, vim.log.levels.ERROR)
		return
	end

	local pip_bin = venv_dir .. "/bin/pip"

	local cmd = string.format(
		"%s -m venv %s && %s install --upgrade pip && %s install manim",
		vim.fn.shellescape(python),
		vim.fn.shellescape(venv_dir),
		vim.fn.shellescape(pip_bin),
		vim.fn.shellescape(pip_bin)
	)

	vim.fn.jobstart({ "bash", "-c", cmd }, {
		on_exit = function(_, code)
			if code == 0 then
				vim.notify("✅ Manim installed: " .. venv_dir, vim.log.levels.INFO)
			else
				vim.notify("❌ Installation failed", vim.log.levels.ERROR)
			end
		end,
	})
end

return M
