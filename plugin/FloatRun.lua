vim.cmd [[ 
command! FloatRun :lua require('FloatRun').float_run("default")
command! FloatTerm :lua require('FloatRun').float_run("term")
command! FloatRunToggle :lua require('FloatRun').float_run_toggle("default")
command! FloatTermToggle :lua require('FloatRun').float_run_toggle("term")
]]
