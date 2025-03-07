return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-context',
  },
  event = { 'BufReadPost', 'FileType' },
  config = function()
    local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    parser_config.unifieddiff = {
      install_info = {
        url = 'https://github.com/monaqa/tree-sitter-unifieddiff.git',
        files = { 'src/parser.c', 'src/scanner.c' },
        filetype = 'diff',
      },
    }
    vim.treesitter.language.register('unifieddiff', 'gin')
    vim.treesitter.language.register('unifieddiff', 'gin-diff')

    local parser_install_dir = vim.fs.joinpath(vim.fn.stdpath 'data', 'treesitter')
    vim.opt.rtp:prepend(parser_install_dir)
    require('nvim-treesitter.configs').setup {
      parser_install_dir = parser_install_dir,
      auto_install = true,
      highlight = {
        enable = true,
      },
    }
    require('treesitter-context').setup {
      enable = true,
    }
  end,
}
