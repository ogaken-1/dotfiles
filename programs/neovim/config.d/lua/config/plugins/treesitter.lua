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
      'vim',
      'vimdoc',
      'xml',
      'yaml',
    }
    local ts = require 'nvim-treesitter'
    local ts_dir = vim.fs.joinpath(vim.fn.stdpath 'data', 'nvim-treesitter')
    ts.setup { install_dir = ts_dir }
    vim.opt.runtimepath:prepend(ts_dir)
    ts.install(langs)
    local augroup = vim.api.nvim_create_augroup('config-treesitter', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = augroup,
      pattern = vim.list.unique(vim
        .iter(langs)
        :map(function(lang)
          return vim.treesitter.language.get_filetypes(lang)
        end)
        :flatten()
        :totable()),
      callback = function(ctx)
        vim.treesitter.start(ctx.buf)
      end,
    })
  end,
}
