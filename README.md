## FloatRun
`FloatRun` is a minimize Neovim plugin that lets you run your code in float window.

### FloatRunToggle
![FloatRunToggle](https://github.com/StubbornVegeta/screenshot/blob/master/FloatRunToggle.gif)

### FloatTermToggle
![FloatTermToggle](https://github.com/StubbornVegeta/screenshot/blob/master/FloatTermToggle.gif)

### Installation && Configuration
####  Packer.nvim:
```lua
use {
        'StubbornVegeta/FloatRun',
        config = function()
            require 'module.floatrun'
        end,
        cmd = {'FloatRunToggle', 'FloatTermToggle'}
    }
```

Write the following configuration into `~/.config/nvim/lua/module/floatrun.lua`:
```lua
local file = vim.api.nvim_buf_get_name(0)
require("FloatRun").setup{
    ui = {
        border = "single",
        float_hl = "Normal",
        border_hl = "FloatBorder",
        blend = 0,
        height = 0.8,
        width = 0.8,
        x = 0.5,
        y = 0.5
    },
    run_command = {
        ['cpp'] = 'g++ '..file .. ' -Wall -o ' .. vim.fn.expand('%<') .. ' && ./' .. vim.fn.expand('%<'),
        ['python'] = "python " .. file,
        ['lua'] = "luafile " .. file,
        ['sh'] = "sh " .. file,
        [''] = "",
    }
}
```

#### lazy.nvim

```lua
{
  "StubbornVegeta/FloatRun",
  cmd = "FloatRunToggle",
  opts = function()
    local file = vim.api.nvim_buf_get_name(0)
    return {
      ui = {
        border = "single",
        float_hl = "Normal",
        border_hl = "FloatBorder",
        blend = 0,
        height = 0.8,
        width = 0.8,
        x = 0.5,
        y = 0.5,
      },
      run_command = {
        cpp = "g++ -std=c++11 " .. file .. " -Wall -o " .. vim.fn.expand("%<") .. " && ./" .. vim.fn.expand("%<"),
        python = "python " .. file,
        lua = "luafile " .. file,
        sh = "sh " .. file,
        [""] = "",
      },
    }
  end,
  keys = { { "<F5>", "<cmd>FloatRunToggle<cr>" } },
},
```

### Usage:

```
:FloatRunToggle
:FloatTermToggle
```

### Refer
- [fm-nvim](https://github.com/is0n/fm-nvim/)
