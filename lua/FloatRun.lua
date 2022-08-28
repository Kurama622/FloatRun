local M = {}

local file = vim.api.nvim_buf_get_name(0)

local config = {
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

local function float_win_run(cmd)
  local buf = vim.api.nvim_create_buf(false, true)
  local win_height = math.ceil(vim.api.nvim_get_option("lines") * config.ui.height - 4)
  local win_width = math.ceil(vim.api.nvim_get_option("columns") * config.ui.width)
  local col = math.ceil((vim.api.nvim_get_option("columns") - win_width) * config.ui.x)
  local row = math.ceil((vim.api.nvim_get_option("lines") - win_height) * config.ui.y - 1)
  local opts = {
    style = "minimal",
    relative = "editor",
    border = config.ui.border,
    width = win_width,
    height = win_height,
    row = row,
    col = col
  }
  if (cmd ~= "term") then
    vim.api.nvim_command("write")
  end
  win = vim.api.nvim_open_win(buf, true, opts)
  vim.fn.termopen(cmd)
  vim.api.nvim_command("startinsert")
  vim.api.nvim_win_set_option(
    win,
    "winhl",
    "Normal:" .. config.ui.float_hl .. ",FloatBorder:" .. config.ui.border_hl
    )
  vim.api.nvim_win_set_option(win, "winblend", config.ui.blend)
end

function M.float_run(cmd)
  if (cmd == "default" and config.run_command[vim.bo.filetype]) then
    float_win_run(config.run_command[vim.bo.filetype])
  elseif (cmd == "term") then
    float_win_run("$SHELL")
  else
    print("\nFileType not supported\n")
  end
end


function M.setup(custom_config) 
  config = vim.tbl_deep_extend("force", config, custom_config)
end

return M
