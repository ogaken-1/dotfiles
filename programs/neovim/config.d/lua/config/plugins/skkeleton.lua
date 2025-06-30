local function read_dict(dir)
  return vim
    ---@diagnostic disable-next-line: param-type-mismatch
    .iter(vim.fn.readdir(dir, 'v:val =~# "^SKK-JISYO"'))
    :map(function(fname)
      return vim.fs.joinpath(dir, fname)
    end)
    :totable()
end
return {
  'vim-skk/skkeleton',
  dependencies = {
    'vim-denops/denops.vim',
    'delphinus/skkeleton_indicator.nvim',
  },
  config = function()
    require('config.skkeleton-azik').load()
    vim.fn['denops#plugin#wait_async']('skkeleton', function()
      local dict_dir = vim.fs.joinpath(vim.env.HOME, '.nix-profile/share/skk')
      vim.fn['skkeleton#config'] {
        kanaTable = 'azik',
        completionRankFile = vim.fs.joinpath(vim.uv.os_getenv 'XDG_DATA_HOME', 'skk', 'rank.json'),
        eggLikeNewline = false,
        globalDictionaries = read_dict(dict_dir),
        sources = { 'skk_dictionary' },
        userDictionary = vim.fs.joinpath(vim.uv.os_getenv 'XDG_DATA_HOME', 'skk', 'user-jisyo'),
        immediatelyCancel = true,
      }
      require('skkeleton_indicator').setup()
    end)
    vim.keymap.set({ 'i', 'c' }, '<C-j>', '<Plug>(skkeleton-enable)')
  end,
}