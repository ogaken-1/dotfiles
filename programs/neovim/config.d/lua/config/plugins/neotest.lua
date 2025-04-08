return {
  'nvim-neotest/neotest',
  event = { 'FileType' },
  dependencies = {
    'nvim-neotest/nvim-nio',
    'Issafalcon/neotest-dotnet',
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-dotnet',
      },
    }
  end,
}
