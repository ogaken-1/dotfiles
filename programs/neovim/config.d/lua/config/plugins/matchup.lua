return {
  'andymass/vim-matchup',
  event = 'BufReadPost',
  init = function()
    vim.g.loaded_matchit = 1
  end,
  config = function()
    vim.keymap.del('i', '<C-g>%')
    local ok, tsconfig = pcall(require, 'nvim-treesitter.configs')
    if ok then
      tsconfig.setup {
        matchup = {
          enable = true,
        },
      }
    end
  end,
}
