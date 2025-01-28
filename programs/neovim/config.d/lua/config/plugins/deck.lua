return {
  'hrsh7th/nvim-deck',
  cmd = 'Deck',
  config = function()
    require('deck.easy').setup()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'DeckStart',
      callback = function(e)
        local deck = require 'deck'
        local ctx = e.data.ctx
        ctx.keymap('n', '<Esc>', function()
          ctx.set_preview_mode(false)
        end)
        ctx.keymap('n', '<Tab>', deck.action_mapping 'choose_action')
        ctx.keymap('n', '<C-l>', deck.action_mapping 'refresh')
        ctx.keymap('n', 'i', deck.action_mapping 'prompt')
        ctx.keymap('n', 'a', deck.action_mapping 'prompt')
        ctx.keymap('n', '@', deck.action_mapping 'toggle_select')
        ctx.keymap('n', '*', deck.action_mapping 'toggle_select_all')
        ctx.keymap('n', 'p', deck.action_mapping 'toggle_preview_mode')
        ctx.keymap('n', 'd', deck.action_mapping 'delete')
        ctx.keymap('n', '<CR>', deck.action_mapping 'default')
        ctx.keymap('n', 'o', deck.action_mapping 'open')
        ctx.keymap('n', 'O', deck.action_mapping 'open_keep')
        ctx.keymap('n', 's', deck.action_mapping 'open_split')
        ctx.keymap('n', 'v', deck.action_mapping 'open_split')
        ctx.keymap('n', 'N', deck.action_mapping 'create')
        ctx.keymap('n', '<C-u>', deck.action_mapping 'scroll_preview_up')
        ctx.keymap('n', '<C-d>', deck.action_mapping 'scroll_preview_down')
        ctx.keymap('n', 'q', function()
          vim.cmd.close()
        end)
      end,
    })
  end,
}
