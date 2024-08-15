local function mapping()
  local insx = require 'insx'
  insx.add(',', {
    enabled = function()
      return vim.fn['denippet#expandable']()
    end,
    action = function(ctx)
      ctx.send '<Plug>(denippet-expand)'
    end,
  })
  insx.add('<Tab>', {
    enabled = function()
      return vim.fn['denippet#jumpable'](1)
    end,
    action = function(ctx)
      ctx.send '<Plug>(denippet-jump-next)'
    end,
  })
end

return {
  'uga-rosa/denippet.vim',
  dependencies = {
    'vim-denops/denops.vim',
  },
  config = function()
    local dir_path = vim.fs.joinpath(vim.fn.stdpath 'config', 'snippets.d')
    vim.uv.fs_opendir(dir_path, function(err1, dir)
      if err1 ~= nil then
        vim.schedule(function()
          vim.notify(err1, vim.log.levels.ERROR)
        end)
        if dir ~= nil then
          dir:readdir()
        end
        return
      end
      dir:readdir(function(err2, entries)
        dir:closedir()
        if err2 ~= nil then
          vim.schedule(function()
            vim.notify(err2, vim.log.levels.ERROR)
          end)
          return
        end
        if entries == nil then
          vim.notify('config.plugins.denippet.lua: Invalid', vim.log.levels.ERROR)
          return
        end
        local file_names = {}
        for _, entry in ipairs(entries) do
          table.insert(file_names, vim.fs.joinpath(dir_path, entry.name))
        end
        vim.schedule(function()
          for _, fname in ipairs(file_names) do
            vim.fn['denippet#load'](fname)
          end
        end)
      end)
    end, 100)

    -- insxのロードが必要なので、マッピングの登録はInsertEnterまで遅延する
    vim.api.nvim_create_autocmd('InsertEnter', {
      group = vim.api.nvim_create_augroup('config-denippet', { clear = true }),
      once = true,
      callback = mapping,
    })
  end,
}
