return {
  'mattn/vim-sonictemplate',
  cmd = 'SonicTemplate',
  ft = 'stpl',
  init = function()
    vim.filetype.add {
      extension = {
        stpl = 'stpl',
      },
    }
    vim.g.sonictemplate_commandname = 'SonicTemplate'
    vim.g.sonictemplate_vim_template_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'sonictemplate')
  end,
}
