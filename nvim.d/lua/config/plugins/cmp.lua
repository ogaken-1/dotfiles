local function setup_normal_sources()
  local cmp = require 'cmp'
  cmp.setup {
    sources = cmp.config.sources({
      { name = 'denippet' },
      { name = 'nvim_lsp' },
    }, {
      { name = 'buffer' },
    }),
  }
end
local function setup_skk_source()
  local cmp = require 'cmp'
  cmp.setup {
    sources = cmp.config.sources {
      { name = 'skkeleton' },
    },
  }
end

return {
  'hrsh7th/nvim-cmp',
  event = { 'InsertEnter', 'CmdlineEnter' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'uga-rosa/cmp-denippet',
    'uga-rosa/cmp-skkeleton',
    'hrsh7th/cmp-cmdline',
  },
  config = function()
    local cmp = require 'cmp'
    cmp.setup {
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      },
      window = {
        completion = {
          border = 'single',
        },
        documentation = {
          border = 'single',
        },
      },
      experimental = {
        ghost_text = true,
      },
    }
    cmp.setup.cmdline(':', {
      mapping = {
        ['<Tab>'] = {
          c = function()
            if cmp.visible() then
              cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
            else
              cmp.complete()
            end
          end,
        },
        ['<S-Tab>'] = {
          c = function()
            if cmp.visible() then
              cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
            else
              cmp.complete()
            end
          end,
        },
      },
      sources = cmp.config.sources {
        {
          name = 'cmdline',
          option = {
            ignore_cmds = { 'Man', '!' },
          },
        },
      },
    })
    setup_normal_sources()
    local gid = vim.api.nvim_create_augroup('config-cmp', { clear = true })
    vim.api.nvim_create_autocmd('User', {
      group = gid,
      pattern = 'skkeleton-enable-post',
      callback = setup_skk_source,
    })
    vim.api.nvim_create_autocmd('User', {
      group = gid,
      pattern = 'skkeleton-disable-post',
      callback = setup_normal_sources,
    })
  end,
}
