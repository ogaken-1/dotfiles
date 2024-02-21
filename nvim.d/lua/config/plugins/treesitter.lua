return {
  'nvim-treesitter/nvim-treesitter',
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

    vim.opt.rtp:prepend(vim.fs.joinpath(vim.fn.stdpath 'data', 'treesitter'))
    require('nvim-treesitter.configs').setup {
      auto_install = true,
      highlight = {
        enable = true,
      },
    }
  end,
}
