return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'Hoffs/omnisharp-extended-lsp.nvim',
    'yioneko/nvim-vtsls',
  },
  event = 'FileType',
  config = function()
    local servers = {
      'biome',
      'denols',
      'gitlab_ci_ls',
      'gopls',
      'jsonls',
      'lua_ls',
      'nixd',
      'omnisharp',
      'rust_analyzer',
      'tinymist',
      'tsp_server',
      'vtsls',
      'yamlls',
    }
    for _, name in ipairs(servers) do
      vim.lsp.enable(name)
    end
  end,
}
