---nvim-lspconfigのサーバー毎の設定ファイルを閲覧する
---@type config.CommandDef
return {
  action = function(params)
    ---@param name? string|string[]
    local function find(name)
      name = name or '*'
      if type(name) == 'table' then
        name = ('(%s)'):format(table.concat(name, '|'))
      end
      local files = vim.fn.globpath(vim.go.runtimepath, ('lua/lspconfig/configs/%s.lua'):format(name), false, true)
      if #files == 0 then
        vim.notify('LspConfigView: no config files found.', vim.log.levels.INFO)
        return
      end
      if #files == 1 then
        vim.cmd.view(files[1])
        return
      end
      local qf_items = {}
      for i, file in ipairs(files) do
        qf_items[i] = {
          filename = file,
          text = vim.fn.fnamemodify(file, ':t:r'),
        }
      end
      vim.fn.setqflist({}, 'r', { items = qf_items })
      vim.cmd.copen()
    end
    local cmdline_args = params.fargs
    if cmdline_args == nil or #cmdline_args < 1 then
      find()
    elseif #cmdline_args == 1 then
      find(cmdline_args[1])
    else
      find(cmdline_args)
    end
  end,
  opts = {
    nargs = '?',
  },
}
