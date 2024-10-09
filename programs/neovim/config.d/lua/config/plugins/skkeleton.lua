return {
  'vim-skk/skkeleton',
  dependencies = {
    'vim-denops/denops.vim',
    'delphinus/skkeleton_indicator.nvim',
  },
  config = function()
    require('config.skkeleton-azik').load()
    vim.fn['denops#plugin#wait_async']('skkeleton', function()
      local dict_dir = vim.env.SKK_DICT_DIRS or '/usr/share/skk'
      local dictionaries = vim
        .iter(vim.fn.split(dict_dir, ':'))
        :map(function(dir)
          return vim
            .iter(vim.fn.readdir(dir, 'v:val =~# "SKK-JISYO"'))
            :map(function(fname)
              return vim.fs.joinpath(dir, fname)
            end)
            :totable()
        end)
        :flatten()
        :totable()
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
