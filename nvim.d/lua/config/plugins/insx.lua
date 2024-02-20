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
        vim.schedule(function()
          local cmp = require 'cmp'
          cmp.confirm { select = true, behavior = cmp.ConfirmBehavior.Replace }
        end)
      end,
    })
    insx.add('<C-g>', {
      enabled = function()
        return require('cmp').visible()
      end,
      action = function()
        vim.schedule(function()
          require('cmp').abort()
        end)
      end,
    })

    do -- C# rules
      insx.add(';', {
        enabled = function(ctx)
          return (ctx.filetype == 'cs' or ctx.filetype == 'razor') and ctx.after() ~= ''
        end,
        action = function(ctx)
          local row = ctx.row()
          ctx.move(row, #vim.fn.getline(row + 1))
          ctx.send ';'
        end,
      })
      for _, word in ipairs { 'if', 'for', 'foreach', 'while' } do
        insx.add('<Space>', {
          enabled = function(ctx)
            return (ctx.filetype == 'cs' or ctx.filetype == 'razor') and (ctx.match([[\<]] .. word .. [[\%#]]))
          end,
          action = function(ctx)
            ctx.send '<Space>()<C-g>U<Left>'
          end,
        })
      end
      insx.add('<Space>', {
        enabled = function(ctx)
          return (ctx.filetype == 'cs' or ctx.filetype == 'razor')
            and (ctx.match [=[\((\|,\s*\)\(out\|var\|await\)\@!\w\+\%#]=])
        end,
        action = function(ctx)
          ctx.send '<Space>=><Space>'
        end,
      })
    end

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

    local auto_pair = require 'insx.recipe.auto_pair'
    local delete_pair = require 'insx.recipe.delete_pair'
    local jump_next = require 'insx.recipe.jump_next'
    local pair_spacing = require 'insx.recipe.pair_spacing'
    local fast_break = require 'insx.recipe.fast_break'
    local esc = insx.helper.regex.esc
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
    for _, pair in ipairs {
      { '"', '"' },
      { '\'', '\'' },
      { '`', '`' },
    } do
      local open_char, close_char = unpack(pair)
      insx.add(
        open_char,
        auto_pair {
          open = open_char,
          close = close_char,
        }
      )
      insx.add(
        '<BS>',
        delete_pair {
          open_pat = esc(open_char),
          close_pat = esc(close_char),
        }
      )
      insx.add(
        '<Tab>',
        jump_next {
          jump_pat = {
            [[\%#]] .. esc(close_char) .. [[\zs]],
          },
        }
      )
    end
  end,
}
