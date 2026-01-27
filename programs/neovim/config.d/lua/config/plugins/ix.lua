return {
  'hrsh7th/nvim-ix',
  dependencies = {
    'hrsh7th/nvim-cmp-kit',
  },
  event = {
    'InsertEnter',
    'CmdlineEnter',
  },
  config = function()
    vim.o.winborder = 'rounded'
    local ix = require 'ix'
    ix.setup {
      expand_snippet = function(snippet)
        vim.snippet.expand(snippet)
      end,
      attach = {
        cmdline_mode = function()
          local service = ix.get_completion_service { recreate = true }
          if vim.fn.getcmdtype() == ':' then
            service:register_source(ix.source.completion.path(), { group = 1 })
            service:register_source(ix.source.completion.cmdline(), { group = 10 })
          end
        end,
      },
    }

    -- menu
    ix.charmap.set({ 'i', 'c' }, '<C-d>', ix.action.scroll(3))
    ix.charmap.set({ 'i', 'c' }, '<C-u>', ix.action.scroll(-3))

    -- cmdline completion
    -- ix.charmap.set('c', '<Tab>', xi.action.completion.complete())
    ix.charmap.set('c', '<Tab>', ix.action.completion.select_next())
    ix.charmap.set('c', '<S-Tab>', ix.action.completion.select_prev())
    ix.charmap.set('c', '<CR>', ix.action.completion.commit_cmdline())

    -- insert mode completion
    ix.charmap.set('i', '<C-o>', ix.action.completion.complete())
    ix.charmap.set('i', '<C-n>', ix.action.completion.select_next())
    ix.charmap.set('i', '<C-p>', ix.action.completion.select_prev())
    ix.charmap.set('i', '<CR>', ix.action.completion.commit { select_first = true, replace = true })

    ix.charmap.set({ 'i', 'c' }, '<C-e>', ix.action.completion.close())

    -- signature help
    ix.charmap.set('i', '<C-o>', ix.action.signature_help.trigger())
    ix.charmap.set('i', '<C-j>', ix.action.signature_help.select_next())
    ix.charmap.set('i', '<C-k>', ix.action.signature_help.select_prev())
  end,
}
