local assert = require 'config.assert'
local function plugin_path(plugin_name)
  return vim.fs.joinpath(assert.string(vim.fn.stdpath 'data'), 'lazy', plugin_name, 'lua')
end

--@type vim.lsp.Config
return {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath 'config'
        and (
          vim.loop.fs_stat(vim.fs.joinpath(path, '.luarc.json'))
          or vim.loop.fs_stat(vim.fs.joinpath(path, '.luarc.jsonc'))
        )
      then
        return
      end
    end
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          '${3rd}/luv/library',
          '${3rd}/busted/library',
          plugin_path 'nvim-insx',
          plugin_path 'snacks.nvim',
        },
        ignoreDir = {
          '**/.direnv',
        },
      },
      format = {
        enable = false,
      },
    })
  end,
  settings = {
    Lua = {},
  },
}
