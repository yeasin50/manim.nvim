# manim.nvim

A small Neovim plugin to run [Manim](https://www.manim.community/) scenes directly from your editor.
Pick the class under the cursor and play it in your terminal without leaving Neovim.

---

## ✨ Features

- Multi-core rendering for faster project exports. All files at once.
- Detects the class under your cursor.
- Verifies that `import manim` is present in the file.
- Checks for a valid `manim` executable:
  - Uses system `manim` if available.(didn't test)
  - Falls back to a provided virtual environment (`venv`).
- Sends play command to your terminal (works with [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)).
- Configurable play/export arguments.

> You have to open terminal(toggleterm)for the first time

---

## Compatibility

This plugin has been tested with:

- Manim Community Edition v0.19.0

---

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
   "yeasin50/manim.nvim",
    cmd = { "ManimCheck", "ManimPlay" , "ManimExport", "ManimExportProject"},
    ft = "python",
    keys = {
       -- modify  as your will
       -- { "<leader>c", "<cmd>ManimCheck<cr>", desc = "Check Manim availability" },
        { "<leader>m", "<cmd>ManimPlay<cr>",  desc = "Play Manim class" },
    },

    config = function()
        require("manim").setup({
            manim_path = "manim", -- system binary
            venv_path = "/home/...../manim/env", -- optional but if you are just using environment,provide full path
            play_args = { "-pql" }, -- quality/preview args
			export_args = {
				"-qk",
				"--media_dir=/home/..../manim_output",
				"--transparent",
			},
        },
     project_config = {
                    resolution = {3840, 2160},           -- width x height
                    fps = 60,                             -- frames per second
                    transparent = true,                   -- transparent background
                    export_dir = "/home/youruser/Videos/manim_exports", -- output directory
                    max_workers = 3,                      -- number of concurrent renders
                    ignore_files = {"common.py", "export.py"},         -- files to skip
                    failed_list_file = "failed_files.txt",             -- log failures
                }
        )
    end,
}
```

## 🚀 Usage

1. Open a Python file that contains Manim scenes.
2. Make sure it has `import manim` or `from manim import ...` at the top.
3. Place your cursor **inside the class definition** of the scene you want to render.
4. Run one of the commands: or use keymap

| Command               | Description                                                                                     |
| --------------------- | ----------------------------------------------------------------------------------------------- |
| `:ManimCheck`         | Verifies Manim is available (system binary or virtual environment).                             |
| `:ManimPlay`          | Renders and plays the scene under the cursor.                                                   |
| `:ManimExport`        | Exports the scene under the cursor using `export_args`.                                         |
| `:ManimExportProject` | Exports all scene files in the project using the Python export script and multi-core rendering. |

> For project export make sure you are at the root of the project where it will have multiple python files.

### Example

```python
from manim import *

class Title(Scene):
    def construct(self):
        self.add(Text("Hello from Manim!"))
```

If your cursor is inside Title and you run:

```cmd
:ManimPlay
```

The plugin will send this command to your terminal:

```bash
manim -pql test.py Title
```

---

## TODO:

- [ ] project based configs
- [x] Export multi-core
- [ ] without toggleterm dependency(but I use it, so maybe I won't work on it
- [ ] ....
