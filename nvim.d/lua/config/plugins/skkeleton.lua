return {
  'vim-skk/skkeleton',
  dependencies = {
    'vim-denops/denops.vim',
  },
  config = function()
    local global_dict_path = '/usr/share/skk'
    vim.uv.fs_opendir(global_dict_path, function(err1, dir)
      if err1 ~= nil then
        vim.schedule(function()
          vim.notify(err1, vim.log.levels.ERROR)
        end)
        if dir ~= nil then
          dir:closedir()
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
          return
        end
        local dictionaries = {}
        for _, entry in ipairs(entries) do
          if entry.type == 'file' and entry.name:sub(1, #'SKK-JISYO') == 'SKK-JISYO' then
            table.insert(dictionaries, vim.fs.joinpath(global_dict_path, entry.name))
          end
        end
        vim.schedule(function()
          vim.fn['denops#plugin#wait_async']('skkeleton', function()
            vim.fn['skkeleton#config'] {
              completionRankFile = vim.fs.joinpath(vim.uv.os_getenv 'XDG_DATA_HOME', 'skk', 'rank.json'),
              eggLikeNewline = true,
              globalDictionaries = dictionaries,
              userDictionary = vim.fs.joinpath(vim.uv.os_getenv 'XDG_DATA_HOME', 'skk', 'user-jisyo'),
            }
          end)
        end)
      end)
    end, 100)
    vim.keymap.set('i', '<C-j>', '<Plug>(skkeleton-enable)')
  end,
}
