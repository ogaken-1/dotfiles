-- tabstopとexpandtabだけ設定するftpluginの場合はここに書いたほうが便利
-- ほかの設定も書いてるときはftpluginでtabstopを設定していることもある

local space2 = {
  'lua',
  'vim',
  'toml',
  'json',
  'jsonc',
  'javascript',
  'typescript',
  'css',
  'xml',
  'sh',
  'zsh',
  'fish',
}

local space4 = {
  'cs',
  'razor',
  'sql',
}

local tab4 = {
  'go',
}

vim.api.nvim_create_autocmd('FileType', {
  group = 'VimRc',
  desc = 'tab幅を設定する',
  callback = function(ctx)
    local ft = ctx.match
    local bufnr = ctx.buf

    if vim.list_contains(space2, ft) then
      vim.bo[bufnr].expandtab = true
      vim.bo[bufnr].tabstop = 2
      vim.bo[bufnr].shiftwidth = 2
    elseif vim.list_contains(space4, ft) then
      vim.bo[bufnr].expandtab = true
      vim.bo[bufnr].tabstop = 4
      vim.bo[bufnr].shiftwidth = 4
    elseif vim.list_contains(tab4, ft) then
      vim.bo[bufnr].expandtab = false
      vim.bo[bufnr].tabstop = 4
      vim.bo[bufnr].shiftwidth = 4
    end
  end,
})
