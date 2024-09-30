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

local function mapping()
  local insx = require 'insx'
  insx.add('<C-n>', {
    enabled = function()
      return require('cmp').visible()
    end,
    action = function()
      local cmp = require 'cmp'
      cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
    end,
  })
  insx.add('<C-p>', {
    enabled = function()
      return require('cmp').visible()
    end,
    action = function()
      local cmp = require 'cmp'
      cmp.select_prev_item { behavior = cmp.SelectBehavior.Select }
    end,
  })
  insx.add('<CR>', {
    enabled = function()
      return require('cmp').visible()
    end,
    action = function()
      vim.schedule(function()
        local cmp = require 'cmp'
        cmp.confirm { select = true, behavior = cmp.ConfirmBehavior.Replace }
      end)
    end,
    priority = 1,
  })
  insx.add('<C-g>', {
    enabled = function()
      return require('cmp').visible()
    end,
    action = function()
      vim.schedule(function()
        require('cmp').abort()
      end)
    end,
  })
end

return {
  'hrsh7th/nvim-cmp',
  event = { 'InsertEnter', 'CmdlineEnter' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'uga-rosa/cmp-denippet',
    'uga-rosa/cmp-skkeleton',
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

    mapping()

    vim.api.nvim_create_autocmd('InsertLeave', {
      group = gid,
      callback = function()
        vim.o.virtualedit = 'none'
      end,
    })
  end,
}
