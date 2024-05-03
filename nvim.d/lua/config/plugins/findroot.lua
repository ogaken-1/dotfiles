return {
  'mattn/vim-findroot',
  events = { 'BufReadPost', 'BufNewFile' },
  init = function()
    vim.g.findroot_patterns = {
      '.git/',
      '*.sln',
      'package.json',
      'deno.json',
      'deno.jsonc',
      'Cargo.toml',
    }
  end,
}
