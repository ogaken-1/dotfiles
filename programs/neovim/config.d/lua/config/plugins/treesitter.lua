return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  event = { 'BufReadPost', 'FileType' },
  config = function()
    local langs = {
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
    }
    local ts = require 'nvim-treesitter'
    ts.setup()
    ts.install(langs)
    local augroup = vim.api.nvim_create_augroup('config-treesitter', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = augroup,
      pattern = vim
        .iter(langs)
        :map(function(lang)
          return '*.' .. lang
        end)
        :totable(),
      callback = function(ctx)
        vim.treesitter.start(ctx.buf)
      end,
    })
  end,
}
