local M = {}

local opts = {}
local state = {
  workspace = {
    cmd = {
      { opened = false, created = false, bufid = -1 },
    },
    term = {
      { opened = false, created = false, bufid = -1 },
    },
  },
  index = {
    cmd = 0,
    term = 0,
  },
}

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

local function _run(cmd)
  local win_height = math.ceil(vim.api.nvim_get_option_value("lines", { scope = "local" }) * config.ui.height - 4)
  local win_width = math.ceil(vim.api.nvim_get_option_value("columns", { scope = "local" }) * config.ui.width)
  local col = math.ceil((vim.api.nvim_get_option_value("columns", { scope = "local" }) - win_width) * config.ui.x)
  local row = math.ceil((vim.api.nvim_get_option_value("lines", { scope = "local" }) - win_height) * config.ui.y - 1)
  opts = {
    style = "minimal",
    relative = "editor",
    border = config.ui.border,
    width = win_width,
    height = win_height,
    row = row,
    col = col,
  }
  local win = nil
  local idx = state.index
  print("idx: " .. vim.inspect(idx))
  if cmd ~= "$SHELL" then
    state.workspace.cmd[idx.cmd].bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("write")
    win = vim.api.nvim_open_win(state.workspace.cmd[idx.cmd].bufid, true, opts)
  else
    state.workspace.term[idx.term].bufid = vim.api.nvim_create_buf(false, true)
    win = vim.api.nvim_open_win(state.workspace.term[idx.term].bufid, true, opts)
  end
  vim.fn.jobstart(cmd, { term = true })
  vim.api.nvim_command("startinsert")
  vim.api.nvim_set_option_value(
    "winhl",
    "Normal:" .. config.ui.float_hl .. ",FloatBorder:" .. config.ui.border_hl,
    { win = win }
  )
  vim.api.nvim_set_option_value("winblend", config.ui.blend, { win = win })
  return win
end

function M.float_run(cmd, ...)
  local args = { ... }
  local file = args[1]
  local bin = args[2]

  local idx = state.index
  if cmd == "default" and config.run_command[vim.bo.filetype] then
    idx.cmd = idx.cmd + 1
    local str = string.format(config.run_command[vim.bo.filetype], file)
    local run_command_str = string.gsub(str, "{}", bin)
    _run(run_command_str)
    state.workspace.cmd[idx.cmd].opened = true
  elseif cmd == "term" then
    idx.term = idx.term + 1
    _run("$SHELL")
    state.workspace.term[idx.term].opened = true
  else
    vim.notify("FileType not supported!", vim.log.levels.WARN)
  end
end

function M.float_run_toggle(cmd, ...)
  local args = { ... }
  local file = args[1]
  local bin = args[2]
  local idx = state.index
  if cmd == "default" and config.run_command[vim.bo.filetype] then
    local workspace_cmd = state.workspace.cmd[idx.cmd]
    if not workspace_cmd or not vim.api.nvim_buf_is_valid(workspace_cmd.bufid) then
      if not workspace_cmd then
        idx.cmd = idx.cmd + 1
        workspace_cmd = state.workspace.cmd[idx.cmd]
      end
      workspace_cmd.opened = false
      workspace_cmd.created = false
    end
    if workspace_cmd.opened then
      vim.api.nvim_win_close(0, false)
      workspace_cmd.opened = false
    elseif workspace_cmd.created then
      vim.api.nvim_open_win(workspace_cmd.bufid, true, opts)
      workspace_cmd.opened = true
    else
      local str = string.format(config.run_command[vim.bo.filetype], file)
      local run_command_str = string.gsub(str, "{}", bin)
      _run(run_command_str)
      workspace_cmd.opened = true
      workspace_cmd.created = true
    end
  elseif cmd == "term" then
    local workspace_term = state.workspace.term[idx.term]
    if not workspace_term or not vim.api.nvim_buf_is_valid(workspace_term.bufid) then
      if not workspace_term then
        idx.term = idx.term + 1
        workspace_term = state.workspace.term[idx.term]
      end
      workspace_term.opened = false
      workspace_term.created = false
    end
    if not vim.api.nvim_buf_is_valid(workspace_term.bufid) then
      workspace_term.opened = false
      workspace_term.created = false
    end
    if workspace_term.opened then
      vim.api.nvim_win_close(0, false)
      workspace_term.opened = false
    elseif workspace_term.created then
      vim.api.nvim_open_win(workspace_term.bufid, true, opts)
      vim.api.nvim_command("startinsert")
      workspace_term.opened = true
    else
      _run("$SHELL")
      workspace_term.opened = true
      workspace_term.created = true
    end
  else
    print("\nFileType not supported\n")
  end
end

function M.setup(custom_config)
  config = vim.tbl_deep_extend("force", config, custom_config)
end

return M
