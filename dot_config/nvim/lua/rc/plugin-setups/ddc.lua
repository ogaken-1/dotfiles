vim.api.nvim_create_autocmd({ 'InsertEnter', 'CmdlineEnter' }, {
  group = 'VimRc',
  once = true,
  callback = function()
    if vim.g.did_ddc_setup then
      return
    end
    vim.g.did_ddc_setup = true

    vim.fn['ddc#custom#load_config'](vim.fs.joinpath(vim.env.DEIN_CONFIG_DIR, 'ddc.ts'))
    vim.fn['ddc#enable']()
    local preview = require 'ddc_preview'
    preview.setup {
      ui = 'native',
      window_options = {
        wrap = false,
        number = false,
        relativenumber = false,
        signcolumn = 'no',
        foldenable = false,
        foldcolumn = '0',
      },
    }
    preview.enable()
  end,
})

-- vim.api.nvim_create_autocmd('CmdlineEnter', {
--   group = 'VimRc',
--   desc = 'call ddc#enable_cmdline_completion()',
--   callback = function()
--     vim.fn['ddc#enable_cmdline_completion']()
--   end,
-- })
