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
      ensure_installed = {
        'bash',
        'c',
        'c_sharp',
        'commonlisp',
        'css',
        'csv',
        'diff',
        'dockerfile',
        'editorconfig',
        'embedded_template',
        'fish',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'html',
        'ini',
        'javascript',
        'json',
        'jsonc',
        'lua',
        'make',
        'markdown',
        'mermaid',
        'nix',
        'pod',
        'powershell',
        'prisma',
        'query',
        'razor',
        'ruby',
        'sql',
        'ssh_config',
        'terraform',
        'tmux',
        'toml',
        'tsx',
        'typescript',
        'typespec',
        'typst',
        'unifieddiff',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      },
      auto_install = false,
      highlight = {
        enable = true,
      },
    }
    require('treesitter-context').setup {
      -- 普段から有効化しているとちょっとウザいので
      -- 欲しいときに:TSContextEnableを使って有効化する
      enable = false,
    }
  end,
}
