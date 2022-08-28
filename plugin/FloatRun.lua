vim.cmd [[ 
command! FloatRun :lua require('FloatRun').float_run("default")
command! FloatTerm :lua require('FloatRun').float_run("term")
]]
