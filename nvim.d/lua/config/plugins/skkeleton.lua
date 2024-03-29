return {
  'vim-skk/skkeleton',
  dependencies = {
    'vim-denops/denops.vim',
    'delphinus/skkeleton_indicator.nvim',
  },
  config = function()
    require('config.skkeleton-azik').load()
    vim.fn['denops#plugin#wait_async']('skkeleton', function()
      local global_dict_path = vim.env.SKK_DICT_DIR or '/usr/share/skk'
      local dictionaries = {}
      local files =
        vim.fn.readdir(global_dict_path, [=[['L', 'jinmei', 'geo']->index(v:val->fnamemodify(':e')) != -1]=])
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
        sources = { 'skk_dictionary' },
        userDictionary = vim.fs.joinpath(vim.uv.os_getenv 'XDG_DATA_HOME', 'skk', 'user-jisyo'),
        immediatelyCancel = true,
      }
      require('skkeleton_indicator').setup()
    end)
    vim.keymap.set({ 'i', 'c' }, '<C-j>', '<Plug>(skkeleton-enable)')
  end,
}
