return {
  'folke/snacks.nvim',
  ---@type snacks.Config
  opts = {
    input = {},
    picker = {
      ui_select = true,
      sources = {
        lines = {
          matcher = {
            smartcase = true,
            fuzzy = false,
          },
        },
      },
    },
    styles = {
      input = {
        relative = 'cursor',
      },
    },
  },
  keys = {
    '<Plug>(git)',
    '<Plug>(ff)',
    '<Plug>(lsp-references)',
    '<Plug>(lsp-implementations)',
  },
  config = function(_, opts)
    Snacks.setup(opts)
    -- picker
    vim.keymap.set('n', '<Plug>(ff)f', Snacks.picker.files)
    vim.keymap.set('n', '<Plug>(ff)b', Snacks.picker.buffers)
    vim.keymap.set('n', '<Plug>(ff)f', Snacks.picker.smart)
    vim.keymap.set('n', '<Plug>(ff)h', Snacks.picker.help)
    vim.keymap.set('n', '<Plug>(ff)/', Snacks.picker.lines)
    vim.keymap.set('n', '<Plug>(ff)?', Snacks.picker.grep)
    -- lsp
    vim.keymap.set('n', '<Plug>(lsp-references)', Snacks.picker.lsp_references)
    vim.keymap.set('n', '<Plug>(lsp-implementations)', Snacks.picker.lsp_implementations)
  end,
}
