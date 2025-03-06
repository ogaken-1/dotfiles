local fn = vim.fn

vim.keymap.set('n', '<C-n>', function()
  local search_word = vim.fn.getreg '/'
  -- When no matches found, :vimgrep cause error
  pcall(vim.cmd.vimgrep, { ('\'%s\''):format(search_word), '%' })
end)
vim.keymap.set('n', 'U', '<C-r>')
vim.keymap.set('n', '<Space>a', '<Plug>(git)')
vim.keymap.set('n', '<Space>f', '<Plug>(ff)')
vim.keymap.set('n', '<Space>e', '<Plug>(filer:drawer)')
vim.keymap.set({ 'n', 'x' }, '<Space>y', '"+y')
vim.keymap.set({ 'n', 'x' }, '<Space>p', '"+p')
vim.keymap.set('n', 'mf', '<Plug>(run-format)')
for _, key in ipairs { 'i', 'a' } do
  vim.keymap.set('n', key, function()
    if #fn.getline(fn.line '.') == 0 then
      return '"_cc'
    else
      return key
    end
  end, { expr = true, desc = '空の行ではインデントする' })
end
