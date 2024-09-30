return {
  add = function()
    local insx = require 'insx'
    local u = require 'config.plugins.insx.utils'
    ---@param key string
    ---@param at string
    ---@param recipe insx.RecipeSource | fun(ctx: insx.Context) | string
    local function add(key, at, recipe)
      insx.add(key, insx.with(u.normalize(recipe), { insx.with.filetype 'ruby', insx.with.match(at) }))
    end
    add('<CR>', [[\%(if\|class\)\s.\+\%#$]], function(ctx)
      ctx.send '<CR>'
      local row, col = ctx.row(), ctx.col()
      ctx.send '<CR>end'
      ctx.move(row, col)
      ctx.send((' '):rep(col))
    end)
  end,
}
