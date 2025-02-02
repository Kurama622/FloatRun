local M = {}

local opts = {
  style = "minimal",
  relative = "editor",
  border = "rounded",
  width = 0.8,
  height = 0.8,
  row = 0.5,
  col = 0.5,
  title = "",
  title_pos = "center",
}
local state = {
  workspace = {
    cmd = {},
    term = { { opened = false, created = false, bufid = -1 } },
  },
  index = {
    cmd = 0,
    term = 0,
  },
  cnt = {
    cmd = 0,
    term = 0,
  },
  enable_title = false,
}

local config = {
  ui = {
    border = "single",
    float_hl = "Normal",
    border_hl = "FloatBorder",
    blend = 0,
    height = 0.8,
    width = 0.8,
    title_pos = "center",
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
  opts.border = config.ui.border
  opts.width = win_width
  opts.height = win_height
  opts.row = row
  opts.col = col

  local win = nil
  local idx = state.index
  if cmd ~= "$SHELL" then
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
    state.workspace.cmd[idx.cmd].bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("write")
    win = vim.api.nvim_open_win(state.workspace.cmd[idx.cmd].bufid, true, opts)
    vim.api.nvim_set_option_value("filetype", "FloatRun", { buf = state.workspace.cmd[idx.cmd].bufid })
    vim.fn.jobstart(cmd, { term = true })
    vim.api.nvim_command("startinsert")
    vim.api.nvim_buf_set_name(state.workspace.cmd[idx.cmd].bufid, "[output] " .. filename)
  else
    local filename = "Terminal " .. tostring(idx.term)
    state.workspace.term[idx.term].bufid = vim.api.nvim_create_buf(false, true)
    win = vim.api.nvim_open_win(state.workspace.term[idx.term].bufid, true, opts)
    vim.fn.jobstart(cmd, { term = true })
    vim.api.nvim_command("startinsert")
    vim.api.nvim_set_option_value("filetype", "FloatTerm", { buf = state.workspace.term[idx.term].bufid })
    vim.api.nvim_buf_set_name(state.workspace.term[idx.term].bufid, filename)
  end
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
  local cnt = state.cnt
  if cmd == "default" and config.run_command[vim.bo.filetype] then
    table.insert(state.workspace.cmd, { opened = false, created = false, bufid = -1 })
    idx.cmd = idx.cmd + 1
    local str = string.format(config.run_command[vim.bo.filetype], file)
    local run_command_str = string.gsub(str, "{}", bin)
    _run(run_command_str)
    state.workspace.cmd[idx.cmd].opened = true
  elseif cmd == "term" then
    table.insert(state.workspace.term, { opened = false, created = false, bufid = -1 })
    idx.term = idx.term + 1
    cnt.term = cnt.term + 1
    if cnt.term > 1 then
      state.enable_title = true
      opts.title = string.format("[ %s/%s ]", state.index.term, state.cnt.term)
    else
      state.enable_title = false
      opts.title = ""
    end
    _run("$SHELL")
    state.workspace.term[idx.term].opened = true
    state.workspace.term[idx.term].created = true
  else
    vim.notify("FileType not supported!", vim.log.levels.WARN, { title = "FloatRun" })
  end
end

function M.float_run_toggle(cmd, ...)
  local args = { ... }
  local file = args[1]
  local bin = args[2]
  local idx = state.index
  local cnt = state.cnt
  if vim.bo.filetype == "FloatRun" then
    -- vim.notify("Hide CMD", vim.log.levels.INFO, { title = "FloatRun" })
    local workspace_cmd = state.workspace.cmd[idx.cmd]
    local success, _ = pcall(vim.api.nvim_win_close, 0, false)
    if not success then
      vim.notify(
        "Last time when the window was closed, the buffer was not cleared.",
        vim.log.levels.WARN,
        { title = "FloatRun" }
      )
    end
    workspace_cmd.opened = false
  elseif cmd == "default" and config.run_command[vim.bo.filetype] then
    local workspace_cmd = state.workspace.cmd[idx.cmd]
    if not workspace_cmd or not vim.api.nvim_buf_is_valid(workspace_cmd.bufid) then
      if not workspace_cmd then
        -- vim.notify("Create CMD", vim.log.levels.INFO, { title = "FloatRun" })
        table.insert(state.workspace.cmd, { opened = false, created = false, bufid = -1 })
        idx.cmd = idx.cmd + 1
        workspace_cmd = state.workspace.cmd[idx.cmd]
      else
        workspace_cmd.opened = false
        workspace_cmd.created = false
      end
    end
    if workspace_cmd.opened then
      local success, _ = pcall(vim.api.nvim_win_close, 0, false)
      if not success then
        vim.notify(
          "Last time when the window was closed, the buffer was not cleared.",
          vim.log.levels.WARN,
          { title = "FloatRun" }
        )
      end
      workspace_cmd.opened = false
    elseif workspace_cmd.created then
      -- vim.notify("Show CMD", vim.log.levels.INFO, { title = "FloatRun" })
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
    if vim.bo.filetype == "FloatTerm" then
      -- vim.notify("Hide TERM", vim.log.levels.INFO, { title = "FloatRun" })
      workspace_term = state.workspace.term[idx.term]
      local success, _ = pcall(vim.api.nvim_win_close, 0, false)
      if not success then
        vim.notify(
          "Last time when the window was closed, the buffer was not cleared.",
          vim.log.levels.WARN,
          { title = "FloatRun" }
        )
      end
      workspace_term.opened = false
    else
      if not workspace_term or not vim.api.nvim_buf_is_valid(workspace_term.bufid) then
        if not workspace_term then
          -- vim.notify("Create TERM", vim.log.levels.INFO, { title = "FloatRun" })
          idx.term = idx.term + 1
          cnt.term = cnt.term + 1
          workspace_term = state.workspace.term[idx.term]
        elseif idx.term > 1 then
          idx.term = idx.term - 1
          workspace_term = state.workspace.term[idx.term]
        else
          workspace_term.opened = false
          workspace_term.created = false
        end
      end
      if workspace_term.created then
        if cnt.term > 1 then
          state.enable_title = true
          opts.title = string.format("[ %s/%s ]", state.index.term, state.cnt.term)
        else
          state.enable_title = false
          opts.title = ""
        end
        -- vim.notify("Show TERM " .. tostring(idx.term), vim.log.levels.INFO, { title = "FloatRun" })
        vim.api.nvim_open_win(workspace_term.bufid, true, opts)
        vim.api.nvim_command("startinsert")
        workspace_term.opened = true
      else
        _run("$SHELL")
        workspace_term.opened = true
        workspace_term.created = true
      end
    end
  else
    vim.notify("FileType not supported!", vim.log.levels.WARN, { title = "FloatRun" })
  end
end

function M.setup(conf)
  config = vim.tbl_deep_extend("force", config, conf)
  opts.title_pos = config.ui.title_pos
  vim.api.nvim_create_autocmd("QuitPre", {
    callback = function(args)
      local bufnr = args.buf
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

      if filetype == "FloatRun" then
        table.remove(state.workspace.cmd, state.index.cmd)
        state.index.cmd = state.index.cmd - 1
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
    end,
  })
  vim.api.nvim_create_autocmd("TermClose", {
    callback = function(args)
      local bufnr = args.buf
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

      if filetype == "FloatTerm" then
        table.remove(state.workspace.term, state.index.term)
        state.cnt.term = state.cnt.term - 1
        state.index.term = state.index.term - 1
      end
    end,
  })
end

return M
