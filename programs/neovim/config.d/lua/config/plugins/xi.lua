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
    vim.keymap.set({ 'i', 'c' }, '<C-d>', ix.action.scroll(3))
    vim.keymap.set({ 'i', 'c' }, '<C-u>', ix.action.scroll(-3))

    -- cmdline completion
    -- vim.keymap.set('c', '<Tab>', xi.action.completion.complete())
    vim.keymap.set('c', '<Tab>', ix.action.completion.select_next())
    vim.keymap.set('c', '<S-Tab>', ix.action.completion.select_prev())
    vim.keymap.set('c', '<CR>', ix.action.completion.commit_cmdline())

    -- insert mode completion
    vim.keymap.set('i', '<C-o>', ix.action.completion.complete())
    vim.keymap.set('i', '<C-n>', ix.action.completion.select_next())
    vim.keymap.set('i', '<C-p>', ix.action.completion.select_prev())
    vim.keymap.set('i', '<CR>', ix.action.completion.commit { select_first = true, replace = true })

    vim.keymap.set({ 'i', 'c' }, '<C-e>', ix.action.completion.close())

    -- signature help
    vim.keymap.set('i', '<C-o>', ix.action.signature_help.trigger())
    vim.keymap.set('i', '<C-j>', ix.action.signature_help.select_next())
    vim.keymap.set('i', '<C-k>', ix.action.signature_help.select_prev())
  end,
}
