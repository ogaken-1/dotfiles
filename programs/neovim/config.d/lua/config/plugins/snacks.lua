return {
  'folke/snacks.nvim',
  event = {
    'CmdlineEnter',
    'InsertEnter',
  },
  ---@type snacks.Config
  opts = {
    input = {},
    styles = {
      input = {
        relative = 'cursor',
      },
    },
  },
}
