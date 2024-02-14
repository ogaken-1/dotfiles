local cmp = require 'cmp'
local util = require 'rc.utils'
local feedkeys = util.feedkeys
local safeCall = function(name, ...)
  return vim.fn.exists(('*%s'):format(name)) == 1 and vim.fn[name](...)
end

local M = {}

cmp.setup {
  enabled = function()
    -- プロンプトバッファでは無効
    return vim.bo.buftype ~= 'prompt'
  end,
  completion = {
    autocomplete = false,
  },
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },
  window = {
    completion = {
      border = 'rounded',
    },
    documentation = {
      border = 'rounded',
    },
  },
  preselect = cmp.PreselectMode.None,
  experimental = {
    ghost_text = {
      hl_group = 'Comment',
    },
  },
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = require 'lspkind'.cmp_format {
      mode = 'symbol',
      preset = 'codicons',
      menu = {
        luasnip = '[Snippet]',
        tsnip = '[TSnip]',
        copilot = '[Copilot]',
        nvim_lsp = '[LSP]',
        treesitter = '[Tree]',
        nvim_lua = '[Lua]',
        cmp_tabnine = '[Tabnine]',
        buffer = '[Buffer]',
        tmux = '[Tmux]',
        rg = '[Rg]',
        look = '[Look]',
        path = '[Path]',
      },
    },
  },
  sources = cmp.config.sources {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    {
      name = 'buffer',
      option = {
        get_bufnrs = util.getCurrentDisplayedBuffers,
      },
    },
    { name = 'spell' },
    -- { name = 'skkeleton' },
  },
  mapping = {
    ['<CR>'] = function(fallback)
      if cmp.visible() then
        cmp.confirm {
          select = true,
          behavior = cmp.ConfirmBehavior.Replace,
        }
      elseif safeCall 'pum#visible' then
        vim.fn['pum#map#confirm']()
      elseif 1 == vim.fn.pumvisible() then
        if -1 == vim.fn.complete_info().selected then
          feedkeys '<C-n><C-y>'
        else
          feedkeys '<C-y>'
        end
      elseif safeCall 'skkeleton#mode' ~= '' then
        -- NOTE:
        -- skkeletonはhenkan中のnewlineを<NL>で返してくるので、input(direct)の際の<CR>は壊れない
        local chars = string.gsub(
          vim.fn.keytrans(vim.fn['skkeleton#handle']('handleKey', { key = vim.keycode '<CR>', expr = true })),
          '<NL>',
          ''
        )
        feedkeys(vim.keycode(chars))
      else
        fallback()
      end
    end,
    ['<C-n>'] = function()
      if cmp.visible() then
        cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
      elseif safeCall 'pum#visible' then
        vim.fn['pum#map#insert_relative'](1)
      elseif 1 == vim.fn.pumvisible() then
        feedkeys '<C-n>'
      else
        vim.fn['ddc#map#manual_complete']()
        -- cmp.complete()
      end
    end,
    ['<C-p>'] = function()
      if cmp.visible() then
        cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
      elseif safeCall 'pum#visible' then
        vim.fn['pum#map#insert_relative'](-1)
      elseif 1 == vim.fn.pumvisible() then
        feedkeys '<C-p>'
      else
        cmp.complete()
      end
    end,
    ['<C-g>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        feedkeys '<C-e>'
      elseif cmp.visible() then
        cmp.abort()
      elseif safeCall 'pum#visible' then
        vim.fn['pum#map#cancel']()
      else
        fallback()
      end
    end,
    ['<Tab>'] = function(fallback)
      if safeCall('vsnip#jumpable', 1) == 1 then
        feedkeys '<Plug>(vsnip-jump-next)'
      elseif safeCall 'UltiSnips#CanJumpForwards' == 1 then
        feedkeys '<Plug>(ultisnips-jump-next)'
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if safeCall('vsnip#jumpable', -1) == 1 then
        feedkeys '<Plug>(vsnip-jump-prev)'
      elseif safeCall 'UltiSnips#CanJumpBackwards' == 1 then
        feedkeys '<Plug>(ultisnips-jump-previous)'
      else
        fallback()
      end
    end,
  },
}
cmp.setup.cmdline(':', {
  enabled = true,
  mapping = {
    ['<Tab>'] = {
      c = function()
        if cmp.visible() then
          cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
        elseif safeCall 'pum#visible' then
          vim.fn['pum#map#insert_relative'](1)
        else
          feedkeys '<Tab>'
        end
      end,
    },
    ['<S-Tab>'] = {
      c = function()
        if cmp.visible() then
          cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
        elseif safeCall 'pum#visible' then
          vim.fn['pum#map#insert_relative'](-1)
        else
          feedkeys '<S-Tab>'
        end
      end,
    },
    ['<C-g>'] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.close()
        elseif safeCall 'pum#visible' then
          vim.fn['pum#map#cancel']()
        else
          fallback()
        end
      end,
    },
    ['<C-f>'] = {
      c = function()
        if cmp.visible() then
          cmp.close()
        elseif safeCall 'pum#visible' then
          vim.fn['pum#map#cancel']()
        end
        feedkeys '<C-f>'
      end,
    },
  },
  sources = cmp.config.sources {
    { name = 'path' },
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { '!' },
      },
    },
  },
})
cmp.setup.cmdline('/', {
  enabled = true,
  mapping = {
    ['<Tab>'] = {
      c = function()
        if cmp.visible() then
          cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
        elseif safeCall 'pum#visible' then
          vim.fn['pum#map#insert_relative'](1)
          vim.cmd.redraw { bang = true }
        end
      end,
    },
    ['<S-Tab>'] = {
      c = function()
        if cmp.visible() then
          cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
        elseif safeCall 'pum#visible' then
          vim.fn['pum#map#insert_relative'](-1)
        end
      end,
    },
  },
  ['<C-f>'] = function()
    if safeCall 'pum#visible' then
      vim.fn['pum#map#cancel']()
    end
    feedkeys '<C-f>'
  end,
})
cmp.setup.filetype('gitcommit', {
  sources = require 'cmp'.config.sources({
    { name = 'emoji' },
  }, {
    {
      name = 'buffer',
      option = {
        get_bufnrs = util.getCurrentDisplayedBuffers,
      },
    },
  }),
})
cmp.setup.filetype('ddu-ff-filter', {
  sources = {},
})
cmp.setup.filetype('TelescopePrompt', {
  enabled = false,
})
vim.api.nvim_create_autocmd('User', {
  pattern = 'skkeleton-disable-post',
  callback = function()
    require 'cmp'.setup.buffer { enabled = true }
  end,
})
vim.api.nvim_create_autocmd('User', {
  pattern = 'skkeleton-enable-post',
  callback = function()
    require 'cmp'.setup.buffer { enabled = false }
  end,
})

local snippetTrigger = '<Plug>(expand-bracket)'

local function addLeximaRules()
  local rules = {
    { except = [[\%#(]],    input = '(',  input_after = ')' },
    { input = '',           priority = -1 },
    { filetype = 'haskell', input = '' },
  }
  for _, rule in ipairs(rules) do
    vim.fn['lexima#add_rule'](vim.tbl_deep_extend('error', rule, { char = snippetTrigger }))
  end
end

--[[
if nil ~= vim.go.rtp:match 'lexima.vim' then
  addLeximaRules()
else
  vim.api.nvim_create_autocmd('SourcePost', {
    once = true,
    group = 'VimRc',
    pattern = 'lexima.vim',
    callback = addLeximaRules,
  })
end
--]]
-- NOTE: なぜか実行しても問題ない
addLeximaRules()

function M.expandBrackets()
  local leximaExpand = require 'rc.utils'.leximaExpand
  feedkeys(leximaExpand('i', snippetTrigger))
end

vim.api.nvim_create_autocmd('CompleteDone', {
  group = 'VimRc',
  callback = function()
    vim.schedule(function()
      if vim.fn.mode() ~= 'i' then
        return
      end
      local item = vim.v.completed_item
      --NOTE: ddc-source-nvim-lspが渡してくるkind文字列に依存している
      if (item.kind == 'Function') or (item.kind == 'Method') then
        M.expandBrackets()
      end
    end)
  end,
})

cmp.event:on('confirm_done', function(event)
  local function is_function_symbol(item)
    local kind = cmp.lsp.CompletionItemKind
    return (item.kind == kind.Method) or (item.kind == kind.Function) or (item.kind == kind.Constructor)
  end
  local item = event.entry:get_completion_item()
  if ((item.textEdit == nil) or (item.textEdit.newText == item.label)) and is_function_symbol(item) then
    M.expandBrackets()
  end
end)

vim.api.nvim_create_autocmd('User', {
  pattern = 'skkeleton-enable-pre',
  group = 'VimRc',
  desc = 'Retake <CR> handle from skkeleton',
  callback = function(ctx)
    ---@diagnostic disable-next-line: param-type-mismatch, undefined-field
    local rhs = vim.fn.maparg('<CR>', 'i', nil, true).callback
    vim.api.nvim_create_autocmd('User', {
      group = 'VimRc',
      once = true,
      pattern = 'skkeleton-enable-post',
      callback = function()
        vim.keymap.set('i', '<CR>', rhs, { buffer = ctx.buf })
      end,
    })
  end,
})
