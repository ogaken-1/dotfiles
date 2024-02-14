local function add_skk_source()
  vim.api.nvim_create_autocmd('User', {
    pattern = 'skkeleton-enable-post',
    group = 'VimRc',
    callback = function(ctx)
      if vim.b[ctx.buf].ddc_sources ~= nil then
        return
      end
      vim.b[ctx.buf].ddc_sources = vim.fn['ddc#custom#get_current']().sources
      local skkeleton_source = require 'config.plugins.ddc.sources.skkeleton'
      vim.fn['ddc#custom#patch_buffer'] {
        sources = {
          skkeleton_source,
        },
      }
    end,
  })
  vim.api.nvim_create_autocmd('User', {
    pattern = 'skkeleton-disable-post',
    group = 'VimRc',
    callback = function(ctx)
      if vim.b[ctx.buf].ddc_sources == nil then
        return
      end
      vim.fn['ddc#custom#patch_buffer'] {
        sources = vim.b[ctx.buf].ddc_sources,
      }
      vim.b[ctx.buf].ddc_sources = nil
    end,
  })
end

local function setup()
  local sources = {
    nvim_lsp = require 'config.plugins.ddc.sources.nvim-lsp',
    buffer = require 'config.plugins.ddc.sources.buffer',
    vim = require 'config.plugins.ddc.sources.vim',
    cmdline = require 'config.plugins.ddc.sources.cmdline',
    denippet = require 'config.plugins.ddc.sources.denippet',
  }
  local filters = {
    sorters = {
      lsp_kind = require 'config.plugins.ddc.filters.sorter_lsp-kind',
    },
  }
  local ui = vim.env.NVIM_DDC_UI
  if not ((ui == 'native') or (ui == 'pum')) then
    error('Invalid ddc ui name: ' .. ui)
  end
  vim.fn['ddc#custom#patch_global'] {
    ui = ui,
    sources = {
      sources.denippet,
      sources.nvim_lsp,
      sources.buffer,
    },
    cmdlineSources = {
      [':'] = {
        sources.cmdline,
      },
    },
    sourceOptions = {
      ['_'] = {
        dup = 'keep',
      },
    },
    filterParams = {
      ['sorter_lsp-kind'] = filters.sorters.lsp_kind.params,
    },
    specialBufferCompletion = false,
    backspaceCompletion = true,
    autoCompleteEvents = {
      'TextChangedI',
      'TextChangedP',
      'CmdlineChanged',
    },
  }

  add_skk_source()

  vim.fn['ddc#custom#patch_filetype']('vim', {
    sources = {
      sources.vim,
      sources.buffer,
    },
  })

  if vim.env.NVIM_CMDLINE == 'ddc' then
    if vim.fn.mode() == 'c' then
      vim.fn['ddc#enable_cmdline_completion']()
    end
    vim.api.nvim_create_autocmd('CmdlineEnter', {
      group = 'VimRc',
      callback = vim.fn['ddc#enable_cmdline_completion'],
    })
  end
end

return {
  'Shougo/ddc.vim',
  dependencies = {
    'vim-denops/denops.vim',
  },
  init = function()
    vim.api.nvim_create_autocmd('SourcePost', {
      pattern = 'ddc.vim',
      once = true,
      callback = setup,
    })
    vim.api.nvim_create_autocmd({ 'InsertEnter', 'CmdlineEnter' }, {
      group = vim.api.nvim_create_augroup('ddc-enable', {}),
      once = true,
      nested = true,
      callback = function()
        vim.fn['ddc#enable']()
        vim.api.nvim_del_augroup_by_name 'ddc-enable'
      end,
    })
  end,
}
