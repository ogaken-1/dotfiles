return {
  add = function()
    local insx = require 'insx'
    local esc = insx.helper.regex.esc
    local auto_pair = require 'insx.recipe.auto_pair'
    local delete_pair = require 'insx.recipe.delete_pair'
    local jump_next = require 'insx.recipe.jump_next'

    for _, char in ipairs {
      '"',
      '\'',
      '`',
    } do
      insx.add(
        char,
        insx.with(
          auto_pair {
            open = char,
            close = char,
          },
          {
            insx.with.in_string(false),
            insx.with.nomatch [[\w\%#]],
          }
        )
      )

      local after_escaped_quote = ([[\\%s\%%#]]):format(char)
      insx.add(
        '<BS>',
        insx.with({
          action = function(ctx)
            ctx.remove(after_escaped_quote)
          end,
        }, {
          insx.with.in_string(true),
          insx.with.match(after_escaped_quote),
        })
      )

      insx.add(
        '<BS>',
        insx.with(
          delete_pair {
            open_pat = esc(char),
            close_pat = esc(char),
          },
          { insx.with.nomatch(after_escaped_quote) }
        )
      )
      insx.add(
        '<Tab>',
        jump_next {
          jump_pat = {
            [[\%#]] .. esc(char) .. [[\zs]],
          },
        }
      )
    end
  end,
}
