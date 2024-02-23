return {
  'vim-skk/skkeleton',
  dependencies = {
    'vim-denops/denops.vim',
  },
  config = function()
    require('config.skkeleton-azik').load()
    vim.fn['denops#plugin#wait_async']('skkeleton', function()
      local global_dict_path = '/usr/share/skk'
      local dictionaries = {}
      local files = vim.fn.readdir(global_dict_path)
      for _, fname in ipairs(files) do
        if fname:sub(1, #'SKK-JISYO') == 'SKK-JISYO' then
          table.insert(dictionaries, vim.fs.joinpath(global_dict_path, fname))
        end
      end
      vim.fn['skkeleton#config'] {
        kanaTable = 'azik',
        completionRankFile = vim.fs.joinpath(vim.uv.os_getenv 'XDG_DATA_HOME', 'skk', 'rank.json'),
        eggLikeNewline = true,
        globalDictionaries = dictionaries,
        userDictionary = vim.fs.joinpath(vim.uv.os_getenv 'XDG_DATA_HOME', 'skk', 'user-jisyo'),
      }
    end)
    vim.keymap.set('i', '<C-j>', '<Plug>(skkeleton-enable)')
  end,
}
