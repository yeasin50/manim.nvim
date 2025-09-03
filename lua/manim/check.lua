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

return M
