local M = {}

local function empty()
  return nil
end

---@param command_args string[] | string
function M.iter(command_args, opts)
  opts = opts or {}
  local command, args
  if type(command_args) == 'table' then
    command = command_args[1]
    args = {}
    for i = 2, #command_args do
      args[i - 1] = command_args[i]
    end
  else
    command = 'sh'
    args = { '-c', command_args }
  end

  local line_queue = {}
  local is_closed = false
  local error_msg = nil

  local stdout = vim.uv.new_pipe(false)
  if not stdout then
    return empty
  end

  local stderr = vim.uv.new_pipe(false)
  local buffer = ''
  local error_buffer = ''
  local handle, pid

  ---@diagnostic disable-next-line: missing-fields
  handle, pid = vim.uv.spawn(command, {
    args = args,
    stdio = { nil, stdout, stderr },
    cwd = opts.cwd,
  }, function(code, _)
    if code ~= 0 then
      if #error_buffer > 0 then
        error_msg = ('Command failed with exit code %s: %s'):format(tostring(code), error_buffer)
      end
    end
    stdout:close()
    if stderr then
      stderr:close()
    end
    handle:close()
    is_closed = true
  end)
  if not handle then
    error(('Failed to start command: %s'):format(pid))
    return empty
  end
  stdout:read_start(function(err, data)
    if err then
      error_msg = ('Error reading stdout: %s'):format(err)
      is_closed = true
      return
    end
    if data then
      buffer = buffer .. data
      while true do
        local pos = buffer:find '\n'
        if not pos then
          break
        end
        local line = buffer:sub(1, pos - 1)
        buffer = buffer:sub(pos + 1)
        line_queue[#line_queue + 1] = line
      end
    else
      if #buffer > 0 then
        line_queue[#line_queue + 1] = buffer
        buffer = ''
      end
    end
  end)
  if stderr then
    stderr:read_start(function(err, data)
      if err then
        error_msg = ('Error reading stdout: %s'):format(err)
        return
      end
      if data then
        error_buffer = error_buffer .. data
      end
    end)
  end
  return coroutine.wrap(function()
    while true do
      if #line_queue > 0 then
        local line = table.remove(line_queue, 1)
        coroutine.yield(line)
      elseif error_msg then
        error(error_msg)
      elseif is_closed and #line_queue == 0 then
        break
      else
        vim.uv.run 'once'
      end
    end
  end)
end

return M
