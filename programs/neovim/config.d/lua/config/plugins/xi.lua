return {
  'hrsh7th/nvim-xi',
  dependencies = {
    'hrsh7th/nvim-cmp-kit',
  },
  events = {
    'InsertEnter',
    'CmdlineEnter',
  },
  config = function()
    vim.o.winborder = 'rounded'
    local xi = require 'xi'
    vim.lsp.config('*', {
      capabilities = xi.get_capabilities(),
    })
    xi.setup()

    -- menu
    xi.charmap({ 'i', 'c' }, '<C-d>', xi.action.scroll(3))
    xi.charmap({ 'i', 'c' }, '<C-u>', xi.action.scroll(-3))

    -- cmdline completion
    -- xi.charmap('c', '<Tab>', xi.action.completion.complete())
    xi.charmap('c', '<Tab>', xi.action.completion.select_next())
    xi.charmap('c', '<S-Tab>', xi.action.completion.select_prev())
    xi.charmap('c', '<CR>', xi.action.completion.commit_cmdline())

    -- insert mode completion
    xi.charmap('i', '<C-o>', xi.action.completion.complete())
    xi.charmap('i', '<C-n>', xi.action.completion.select_next())
    xi.charmap('i', '<C-p>', xi.action.completion.select_prev())
    xi.charmap('i', '<CR>', xi.action.completion.commit { select_first = true, replace = true })

    xi.charmap({ 'i', 'c' }, '<C-e>', xi.action.completion.close())

    -- signature help
    xi.charmap('i', '<C-o>', xi.action.signature_help.trigger())
    xi.charmap('i', '<C-j>', xi.action.signature_help.select_next())
    xi.charmap('i', '<C-k>', xi.action.signature_help.select_prev())
  end,
}
