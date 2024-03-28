vim.cmd([[ 
command! FloatRun :lua require('FloatRun').float_run("default", vim.api.nvim_buf_get_name(0), vim.fn.expand("%<"))
command! FloatTerm :lua require('FloatRun').float_run("term")
command! FloatRunToggle :lua require('FloatRun').float_run_toggle("default", vim.api.nvim_buf_get_name(0), vim.fn.expand("%<"))
command! FloatTermToggle :lua require('FloatRun').float_run_toggle("term")
]])
