## FloatRun
`FloatRun` is a minimize Neovim plugin that lets you run your code in float window.

### FloatRunToggle
![FloatRunToggle](https://github.com/Kurama622/screenshot/blob/master/FloatRunToggle.gif)

### FloatTermToggle
![FloatTermToggle](https://github.com/Kurama622/screenshot/blob/master/FloatTermToggle.gif)

### Installation && Configuration
####  Packer.nvim:
```lua
use {
        'Kurama622/FloatRun',
        config = function()
            require 'module.floatrun'
        end,
        cmd = {'FloatRunToggle', 'FloatTermToggle'}
    }
```

Write the following configuration into `~/.config/nvim/lua/module/floatrun.lua`:
```lua
require("FloatRun").setup{
    ui = {
        relative = "editor",  -- win / editor
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
        ['cpp'] = 'g++ -std=c++11 %s -Wall -o {} && {}',
        ['python'] = "python %s",
        ['lua'] = "lua %s",
        -- ['lua'] = "<builtin>luafile %s",  -- for nvim's built-in cmd
        ['sh'] = "sh %s",
        [''] = "",
    }
}
```

#### lazy.nvim

```lua
{
  "Kurama622/FloatRun",
  cmd = { "FloatRunToggle", "FloatTermToggle" },
  opts = function()
    return {
      ui = {
        relative = "editor", -- win / editor
        border = "single",
        float_hl = "Normal",
        border_hl = "FloatBorder",
        blend = 0,
        height = 0.5,
        width = 0.9,
        x = 0.5,
        y = 0.5,
      },
      run_command = {
        cpp = "g++ -std=c++11 %s -Wall -o {} && {}",
        python = "python %s",
        lua = "lua %s",
        -- lua = "<builtin>luafile %s",  -- for nvim's built-in cmd
        sh = "sh %s",
        [""] = "",
      },
    }
  end,
  keys = {
    { "<F5>", mode = { "n", "t" }, "<cmd>FloatRunToggle<cr>" },
    { "<F2>", mode = { "n", "t" }, "<cmd>FloatTermToggle<cr>" },
    { "<F14>", mode = { "n", "t" }, "<cmd>FloatTerm<cr>" }, -- always create a new terminal
    { "<C-j>", mode = "t", "<cmd>FloatTermNext<cr>" }, -- switch next terminal
    { "<C-k>", mode = "t", "<cmd>FloatTermPrev<cr>" }, -- switch prev terminal
  },
}
```

### Usage:

```
:FloatRunToggle
:FloatTermToggle
```

### Refer
- [fm-nvim](https://github.com/is0n/fm-nvim/)
