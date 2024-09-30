return {
  add = function()
    local insx = require 'insx'
    local u = require 'config.plugins.insx.utils'
    insx.add('>', {
      enabled = function(ctx)
        return (ctx.filetype == 'lua')
          and (vim.treesitter.get_node({ pos = { ctx.row(), ctx.col() } }):type() == 'string')
          and (ctx.match [[<Cmd\%#]])
      end,
      action = function(ctx)
        ctx.send('><lt>CR>' .. (u.left:rep(#'<CR>')))
      end,
    })
  end,
}
