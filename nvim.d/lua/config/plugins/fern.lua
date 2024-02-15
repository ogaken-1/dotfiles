return {
  'lambdalisue/fern.vim',
  cmd = 'Fern',
  init = function()
    vim.keymap.set('n', '<Space>e', function()
      local bufnr = vim.api.nvim_get_current_buf()
      ---@type string
      local dir
      if vim.api.nvim_get_option_value('buftype', { buf = bufnr }) == '' then
        dir = '%:h'
      else
        dir = '.'
      end
      vim.cmd.Fern(dir)
    end)
  end,
}
