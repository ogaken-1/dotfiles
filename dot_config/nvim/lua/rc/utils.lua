return {
  ---Pick a element of list
  ---@generic T
  ---@param list { [number]: T }
  ---@return T
  pick = function(list)
    math.randomseed(os.time())
    return list[math.random(#list)]
  end,
  ---Check string is nil or empty.
  ---@param string any
  ---@return boolean
  nilOrEmpty = function(string)
    return string == nil or string == ''
  end,
  leximaExpand = function(mode, keys)
    return vim.fn.keytrans(vim.fn['lexima#expand'](keys, mode))
  end,
  ---@return integer[]
  getCurrentDisplayedBuffers = function()
    local bufs = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if not (vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'terminal') then
        table.insert(bufs, buf)
      end
    end
    return bufs
  end,
  ---@param keys string
  ---@param flags nil|string
  feedkeys = function(keys, flags)
    vim.api.nvim_feedkeys(vim.keycode(keys), flags or 'nit', false)
  end,
  ---@param bufnr integer
  ---@return string?
  worktree_path = function(bufnr)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local found, path = pcall(vim.fn['gin#util#worktree'], bufname)
    if found then
      return path
    end
  end,
}
