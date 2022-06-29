## FloatRun
`FloatRun` is a Neovim plugin that lets you run you code in float window.
![FloatRun](https://gitee.com/svegeta/screenshot/raw/master/FloatRun.png)

### Installation
For `Packer.nvim`:
```lua
use {
        'StubbornVegeta/FloatRun',
        config = function()
            require 'floatrun'
        end,
        cmd = {'FloatRun'}
    }
```

### Configuration

Write the following configuration into `floatrun.lua`:
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
    }
}

```

### Usage:

```
:FloatRun
```

### Refer
- [fm-nvim](https://github.com/is0n/fm-nvim/)
