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
        ['cpp'] = 'g++ -std=c++11 %s -Wall -o {} && {}',
        ['python'] = "python %s",
        ['lua'] = "lua %s",
        ['sh'] = "sh %s",
        [''] = "",
    }
}
```

#### lazy.nvim

```lua
{
  "StubbornVegeta/FloatRun",
  cmd = { "FloatRunToggle", "FloatTermToggle" },
  opts = function()
    return {
      ui = {
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
        sh = "sh %s",
        [""] = "",
      },
    }
  end,
  keys = {
    { "<F5>", "<cmd>FloatRunToggle<cr>" },
    { "<F2>", mode = { "n", "t" }, "<cmd>FloatTermToggle<cr>" },
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
