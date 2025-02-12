vim.cmd.compiler 'dotnet_build'
require('config.razor').setup(vim.api.nvim_get_current_buf())
