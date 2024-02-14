return {
  'uga-rosa/denippet.vim',
  dependencies = {
    'vim-denops/denops.vim',
  },
  config = function()
    local dir_path = vim.fs.joinpath(vim.fn.stdpath 'config', 'snippets.d')
    vim.uv.fs_opendir(dir_path, function(err1, dir)
      if err1 ~= nil then
        vim.notify(err1, vim.log.levels.ERROR)
        dir:readdir()
        return
      end
      dir:readdir(function(err2, entries)
        dir:closedir()
        if err2 ~= nil then
          vim.notify(err2, vim.log.levels.ERROR)
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
  end,
}
