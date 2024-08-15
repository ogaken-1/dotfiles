local function builtin_snippet()
  local insx = require 'insx'
  insx.add('<Tab>', {
    enabled = function()
      return vim.snippet.active { direction = 1 }
    end,
    action = function()
      vim.snippet.jump(1)
    end,
  })
end
return {
  'hrsh7th/nvim-insx',
  event = 'InsertEnter',
  config = function()
    local setups = {
      builtin_snippet,
      require('config.plugins.insx.bracket').add,
      require('config.plugins.insx.quote').add,
      require('config.plugins.insx.ft.cs').add,
      require('config.plugins.insx.ft.lua').add,
      require('config.plugins.insx.ft.ruby').add,
    }
    for _, fn in ipairs(setups) do
      fn()
    end
  end,
}
