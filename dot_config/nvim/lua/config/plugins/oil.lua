package.loaded['oil'] = setmetatable({}, {
  __index = function(_, key)
    package.loaded['oil'] = nil
    local oil = require 'oil'
    oil.setup()
    return oil[key]
  end,
})

return {
  'stevearc/oil.nvim',
  init = function()
    vim.api.nvim_create_user_command('OilEdit', function(args)
      require('oil').open(args.args)
    end, {
      nargs = 1,
      complete = 'dir',
    })
  end,
}
