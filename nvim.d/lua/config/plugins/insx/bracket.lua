return {
  add = function()
    local insx = require 'insx'
    local esc = insx.helper.regex.esc
    local auto_pair = require 'insx.recipe.auto_pair'
    local delete_pair = require 'insx.recipe.delete_pair'
    local jump_next = require 'insx.recipe.jump_next'
    local pair_spacing = require 'insx.recipe.pair_spacing'
    local fast_break = require 'insx.recipe.fast_break'

    -- '(>\%#)expr'.key('>') → '(expr)\%#'
    insx.add('>', {
      enabled = function(ctx)
        return ctx.match [[(>\%#)]]
      end,
      action = function(ctx)
        ctx.remove [[>\%#)]]
        ---@type string
        local line = ctx.text()
        if vim.fn.match(line, [[;$]]) ~= -1 then
          ctx.move(ctx.row(), #line - 1)
        else
          ctx.move(ctx.row(), #line)
        end
        ctx.send ')'
      end,
    })

    for _, pair in ipairs {
      { '(', ')' },
      { '{', '}' },
      { '[', ']' },
    } do
      local bra, ket = unpack(pair)
      insx.add(
        bra,
        auto_pair {
          open = bra,
          close = ket,
        }
      )
      insx.add(
        '<BS>',
        delete_pair {
          open_pat = esc(bra),
          close_pat = esc(ket),
        }
      )
      insx.add(
        '<Tab>',
        jump_next {
          jump_pat = {
            [[\%#\s*]] .. esc(ket) .. [[\zs]],
          },
        }
      )
      insx.add(
        '<Space>',
        pair_spacing.increase {
          open_pat = esc(bra),
          close_pat = esc(ket),
        }
      )
      insx.add(
        '<BS>',
        pair_spacing.decrease {
          open_pat = esc(bra),
          close_pat = esc(ket),
        }
      )
      insx.add(
        '<CR>',
        fast_break {
          open_pat = esc(bra),
          close_pat = esc(ket),
          arguments = true,
          html_attrs = true,
          html_tags = true,
        }
      )
    end
  end,
}
