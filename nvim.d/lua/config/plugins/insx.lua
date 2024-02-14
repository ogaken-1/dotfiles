return {
  'hrsh7th/nvim-insx',
  event = 'InsertEnter',
  config = function()
    local insx = require 'insx'
    insx.add(',', {
      enabled = function()
        return vim.fn['denippet#expandable']()
      end,
      action = function(ctx)
        ctx.send '<Plug>(denippet-expand)'
      end,
    })
    insx.add('<Tab>', {
      enabled = function()
        return vim.fn['denippet#jumpable'](1)
      end,
      action = function(ctx)
        ctx.send '<Plug>(denippet-jump-next)'
      end,
    })
    insx.add('<Tab>', {
      enabled = function()
        return vim.snippet.jumpable(1)
      end,
      action = function()
        vim.snippet.jump(1)
      end,
    })
    insx.add('<C-n>', {
      enabled = function()
        return require('cmp').visible()
      end,
      action = function()
        local cmp = require 'cmp'
        cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
      end,
    })
    insx.add('<C-p>', {
      enabled = function()
        return require('cmp').visible()
      end,
      action = function()
        local cmp = require 'cmp'
        cmp.select_prev_item { behavior = cmp.SelectBehavior.Select }
      end,
    })
    insx.add('<CR>', {
      enabled = function()
        return require('cmp').visible()
      end,
      action = function()
        local cmp = require 'cmp'
        cmp.confirm { select = true, behavior = cmp.ConfirmBehavior.Replace }
      end,
    })
    local auto_pair = require 'insx.recipe.auto_pair'
    local delete_pair = require 'insx.recipe.delete_pair'
    local jump_next = require 'insx.recipe.jump_next'
    local esc = insx.helper.regex.esc
    for _, pair in ipairs {
      { '(', ')' },
      { '{', '}' },
      { '[', ']' },
      { '"', '"' },
      { '\'', '\'' },
    } do
      insx.add(
        pair[1],
        auto_pair {
          open = pair[1],
          close = pair[2],
        }
      )
      insx.add(
        '<BS>',
        delete_pair {
          open_pat = esc(pair[1]),
          close_pat = esc(pair[2]),
        }
      )
      insx.add(
        '<Tab>',
        jump_next {
          jump_pat = {
            [[\%#]] .. esc(pair[2]) .. [[\zs]],
          },
        }
      )
    end
  end,
}
