return {
  {
    'sainnhe/gruvbox-material',
    init = function()
      vim.api.nvim_create_autocmd('ColorSchemePre', {
        pattern = 'gruvbox-material',
        group = vim.api.nvim_create_augroup('config-colorscheme', { clear = false }),
        callback = function()
          for opt, value in pairs {
            background = 'medium',
            disable_italic_comment = true,
            dim_inactive_windows = true,
            better_performance = true,
          } do
            vim.g['gruvbox_material_' .. opt] = value
          end
        end,
      })
    end,
  },
  { 'kyoh86/momiji' },
}
