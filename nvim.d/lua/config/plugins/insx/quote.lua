return {
  add = function()
    local insx = require 'insx'
    local esc = insx.helper.regex.esc
    local auto_pair = require 'insx.recipe.auto_pair'
    local delete_pair = require 'insx.recipe.delete_pair'
    local jump_next = require 'insx.recipe.jump_next'

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
