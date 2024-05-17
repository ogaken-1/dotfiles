return {
  'folke/flash.nvim',
  event = 'CmdlineEnter',
  opts = {
    labels = 'ASDFGHJKLQWERTYUIOPZXCVBNM',
    label = {
      after = false,
      before = true,
    },
    modes = {
      search = {
        enabled = true,
      },
      char = {
        enabled = false,
      },
    },
  },
}
