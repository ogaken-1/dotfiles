return {
  'hrsh7th/nvim-ix',
  dependencies = {
    'hrsh7th/nvim-cmp-kit',
  },
  events = {
    'InsertEnter',
    'CmdlineEnter',
  },
  config = function()
    vim.o.winborder = 'rounded'
    local ix = require 'ix'
    vim.lsp.config('*', {
      capabilities = ix.get_capabilities(),
    })
    ix.setup {
      expand_snippet = function(snippet)
        vim.snippet.expand(snippet)
      end,
    }

    -- menu
    ix.charmap({ 'i', 'c' }, '<C-d>', ix.action.scroll(3))
    ix.charmap({ 'i', 'c' }, '<C-u>', ix.action.scroll(-3))

    -- cmdline completion
    -- xi.charmap('c', '<Tab>', xi.action.completion.complete())
    ix.charmap('c', '<Tab>', ix.action.completion.select_next())
    ix.charmap('c', '<S-Tab>', ix.action.completion.select_prev())
    ix.charmap('c', '<CR>', ix.action.completion.commit_cmdline())

    -- insert mode completion
    ix.charmap('i', '<C-o>', ix.action.completion.complete())
    ix.charmap('i', '<C-n>', ix.action.completion.select_next())
    ix.charmap('i', '<C-p>', ix.action.completion.select_prev())
    ix.charmap('i', '<CR>', ix.action.completion.commit { select_first = true, replace = true })

    ix.charmap({ 'i', 'c' }, '<C-e>', ix.action.completion.close())

    -- signature help
    ix.charmap('i', '<C-o>', ix.action.signature_help.trigger())
    ix.charmap('i', '<C-j>', ix.action.signature_help.select_next())
    ix.charmap('i', '<C-k>', ix.action.signature_help.select_prev())
  end,
}
