local M = {}

local win_opened = { false, false }
local win_created = { false, false }
local float_win_buf = { -1, -1 }
local opts

local config = {
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
		["cpp"] = "g++ %s -Wall -o {} && {}",
		["python"] = "python %s",
		["lua"] = "luafile %s",
		["sh"] = "sh %s",
		[""] = "",
	},
}

local function float_win_run(cmd)
	local win_height = math.ceil(vim.api.nvim_get_option("lines") * config.ui.height - 4)
	local win_width = math.ceil(vim.api.nvim_get_option("columns") * config.ui.width)
	local col = math.ceil((vim.api.nvim_get_option("columns") - win_width) * config.ui.x)
	local row = math.ceil((vim.api.nvim_get_option("lines") - win_height) * config.ui.y - 1)
	opts = {
		style = "minimal",
		relative = "editor",
		border = config.ui.border,
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}
	local win
	if cmd ~= "$SHELL" then
		float_win_buf[1] = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_command("write")
		win = vim.api.nvim_open_win(float_win_buf[1], true, opts)
	else
		float_win_buf[2] = vim.api.nvim_create_buf(false, true)
		win = vim.api.nvim_open_win(float_win_buf[2], true, opts)
	end
	vim.fn.termopen(cmd)
	vim.api.nvim_command("startinsert")
	vim.api.nvim_win_set_option(win, "winhl", "Normal:" .. config.ui.float_hl .. ",FloatBorder:" .. config.ui.border_hl)
	vim.api.nvim_win_set_option(win, "winblend", config.ui.blend)
	return win
end

function M.float_run(cmd, ...)
	local args = { ... }
	local file = args[1]
	local bin = args[2]
	if cmd == "default" and config.run_command[vim.bo.filetype] then
		local str = string.format(config.run_command[vim.bo.filetype], file)
		local run_command_str = string.gsub(str, "{}", bin)
		float_win_run(run_command_str)
		win_opened[1] = true
	elseif cmd == "term" then
		float_win_run("$SHELL")
		win_opened[2] = true
	else
		print("\nFileType not supported\n")
	end
end

function M.float_run_toggle(cmd, ...)
	local args = { ... }
	local file = args[1]
	local bin = args[2]
	if cmd == "default" and config.run_command[vim.bo.filetype] then
		if not vim.api.nvim_buf_is_valid(float_win_buf[1]) then
			win_opened[1] = false
			win_created[1] = false
		end
		if win_opened[1] then
			vim.api.nvim_win_close(0, false)
			win_opened[1] = false
		elseif win_created[1] then
			vim.api.nvim_open_win(float_win_buf[1], true, opts)
			win_opened[1] = true
		else
			local str = string.format(config.run_command[vim.bo.filetype], file)
			local run_command_str = string.gsub(str, "{}", bin)
			float_win_run(run_command_str)
			win_opened[1] = true
			win_created[1] = true
		end
	elseif cmd == "term" then
		if not vim.api.nvim_buf_is_valid(float_win_buf[2]) then
			win_opened[2] = false
			win_created[2] = false
		end
		if win_opened[2] then
			vim.api.nvim_win_close(0, false)
			win_opened[2] = false
		elseif win_created[2] then
			vim.api.nvim_open_win(float_win_buf[2], true, opts)
			win_opened[2] = true
		else
			float_win_run("$SHELL")
			win_opened[2] = true
			win_created[2] = true
		end
	else
		print("\nFileType not supported\n")
	end
end

function M.setup(custom_config)
	config = vim.tbl_deep_extend("force", config, custom_config)
end

return M
