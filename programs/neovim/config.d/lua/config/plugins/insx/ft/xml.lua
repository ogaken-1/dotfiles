return {
  add = function()
    local insx = require 'insx'
    local substitute = require 'insx.recipe.substitute'
    insx.add(
      '>',
      insx.with(
        substitute {
          pattern = [[<\(\w\+\)[^>]*\%#]],
          replace = [[\0>\%#</\1>]],
        },
        {
          insx.with.filetype 'xml',
          insx.with.in_comment(false),
          insx.with.in_string(false),
        }
      )
    )
    insx.add(
      '/',
      insx.with({
        action = function(ctx)
          ctx.send '/>'
        end,
      }, {
        insx.with.filetype 'xml',
        insx.with.in_comment(false),
        insx.with.in_string(false),
        insx.with.match [[<\w\+[^>]*\%#]],
      })
    )
    insx.add(
      '<BS>',
      insx.with(
        substitute {
          pattern = [[<\(\w\+\).\{-}>\%#</.\{-}>]],
          replace = [[\%#]],
        },
        {
          insx.with.filetype 'xml',
          insx.with.in_comment(false),
          insx.with.in_string(false),
        }
      )
    )
  end,
}
