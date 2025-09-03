local M = {}

-- Check if Manim is available (system or venv)
function M.manim_available(manim_path, venv_path)
	manim_path = manim_path or "manim"

	-- Check system executable
	if vim.fn.executable(manim_path) == 1 then
		return manim_path
	end

	-- Check virtualenv
	if venv_path then
		local venv_manim = venv_path .. "/bin/manim"
		if vim.fn.executable(venv_manim) == 1 then
			return venv_manim
		end
	end

	return nil
end

function M.ensure_python_parser()
	local parsers = require("nvim-treesitter.parsers")
	if not parsers.has_parser("python") then
		vim.notify("[manim.nvim] Treesitter Python parser missing! Installing...", vim.log.levels.INFO)
		-- Trigger automatic install
		vim.cmd("TSInstall python")
		-- Return false to indicate parser was missing (autocmd will continue later)
		return false
	end
	return true
end

return M
