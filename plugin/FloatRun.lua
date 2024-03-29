vim.api.nvim_create_user_command("FloatRun", function()
	local file = vim.api.nvim_buf_get_name(0)
	local bin = vim.fn.fnamemodify(vim.fn.expand("%<"), ":p")
	require("FloatRun").float_run("default", file, bin)
end, {})

vim.api.nvim_create_user_command("FloatTerm", function()
	require("FloatRun").float_run("term")
end, {})

vim.api.nvim_create_user_command("FloatRunToggle", function()
	local file = vim.api.nvim_buf_get_name(0)
	local bin = vim.fn.fnamemodify(vim.fn.expand("%<"), ":p")
	require("FloatRun").float_run_toggle("default", file, bin)
end, {})

vim.api.nvim_create_user_command("FloatTermToggle", function()
	require("FloatRun").float_run_toggle("term")
end, {})
