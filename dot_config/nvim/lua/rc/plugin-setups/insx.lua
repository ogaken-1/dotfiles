local function cmp_visible()
  local ok, cmp = pcall(require, 'cmp')
  return ok and cmp.visible()
end

local function pum_visible()
  return vim.fn.exists '*pum#visible' == 1 and
      vim.fn['pum#visible']()
end

local function wilder_visible()
  return 1 == vim.fn.exists '*wilder#in_context' and
      vim.fn['wilder#in_context']() == 1
end

local setup = function()
  local insx = require 'insx'
  do -- handle <CR>
    insx.add('<CR>', {
      enabled = cmp_visible,
      action = function()
        local cmp = require 'cmp'
        cmp.confirm {
          select = true,
          behavior = cmp.ConfirmBehavior.Replace,
        }
      end,
    })
    insx.add('<CR>', {
      enabled = pum_visible,
      action = function()
        vim.fn['pum#map#confirm']()
      end,
    })
    insx.add('<CR>', {
      enabled = function()
        return 1 == vim.fn.pumvisible()
      end,
      action = function(ctx)
        if -1 == vim.fn.complete_info().selected then
          ctx.send '<C-n><C-y>'
        else
          ctx.send '<C-y>'
        end
      end,
    })
    insx.add('<CR>', {
      priority = -1,
      enabled = function()
        return 1 == vim.fn.exists '*lexima#expand'
      end,
      action = function(ctx)
        ctx.send(vim.fn.keytrans(vim.fn['lexima#expand']('<CR>', 'i')))
      end,
    })
  end

  do -- handle '<C-n>'
    insx.add('<C-n>', {
      enabled = cmp_visible,
      action = function()
        local cmp = require 'cmp'
        cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
      end,
    })
    insx.add('<C-n>', {
      enabled = function()
        return 1 == vim.fn.pumvisible()
      end,
      action = function(ctx)
        ctx.send '<C-n>'
      end,
    })
    insx.add('<C-n>', {
      enabled = pum_visible,
      action = function()
        vim.fn['pum#map#insert_relative'](1)
      end,
    })
    insx.add('<C-n>', {
      priority = -1,
      action = function()
        vim.fn['ddc#map#manual_complete']()
      end
    })
  end

  do -- handle '<C-p>'
    insx.add('<C-p>', {
      enabled = cmp_visible,
      action = function()
        local cmp = require 'cmp'
        cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
      end,
    })
    insx.add('<C-p>', {
      enabled = function()
        return 1 == vim.fn.pumvisible()
      end,
      action = function(ctx)
        ctx.send '<C-p>'
      end,
    })
    insx.add('<C-p>', {
      enabled = pum_visible,
      action = function()
        vim.fn['pum#map#insert_relative'](-1)
      end,
    })
    insx.add('<C-p>', {
      priority = -1,
      action = function()
        vim.fn['ddc#map#manual_complete']()
      end
    })
  end

  do -- handle '<C-g>'
    insx.add('<C-g>', {
      enabled = cmp_visible,
      action = function()
        local cmp = require 'cmp'
        cmp.abort()
      end,
    })
    insx.add('<C-g>', {
      enabled = function()
        return 1 == vim.fn.pumvisible()
      end,
      action = function(ctx)
        ctx.send '<C-e>'
      end,
    })
    insx.add('<C-g>', {
      enabled = pum_visible,
      action = function()
        vim.fn['pum#map#cancel']()
      end,
    })
    insx.add('<C-g>', {
      priority = -1,
      action = function(ctx)
        ctx.send '<C-g>'
      end
    })
  end

  do -- handle '<Tab>'
    insx.add('<Tab>', {
      enabled = function()
        return vim.fn.exists '*vsnip#jumpable' == 1 and vim.fn['vsnip#jumpable'](1) == 1
      end,
      action = function(ctx)
        ctx.send '<Plug>(vsnip-jump-next)'
      end,
    })
    insx.add('<Tab>', {
      enabled = function()
        return vim.fn.exists '*UltiSnips#CanJumpForwards' == 1 and vim.fn['UltiSnips#CanJumpForwards']() == 1
      end,
      action = function(ctx)
        ctx.send '<Plug>(ultisnips-jump-next)'
      end,
    })
    insx.add('<Tab>', {
      priority = -1,
      enabled = function()
        return 1 == vim.fn.exists '*lexima#expand'
      end,
      action = function(ctx)
        ctx.send(vim.fn.keytrans(vim.fn['lexima#expand']('<TAB>', 'i')))
      end,
    })
  end

  do -- handle '<S-Tab>'
    insx.add('<S-Tab>', {
      enabled = function()
        return vim.fn.exists '*vsnip#jumpable' == 1 and vim.fn['vsnip#jumpable'](1) == 1
      end,
      action = function(ctx)
        ctx.send '<Plug>(vsnip-jump-next)'
      end,
    })
    insx.add('<S-Tab>', {
      enabled = function()
        return vim.fn.exists '*UltiSnips#CanJumpBackwards' == 1 and vim.fn['UltiSnips#CanJumpBackwards']() == 1
      end,
      action = function(ctx)
        ctx.send '<Plug>(ultisnips-jump-previous)'
      end,
    })
    insx.add('<S-Tab>', {
      priority = -1,
      enabled = function()
        return 1 == vim.fn.exists '*lexima#expand'
      end,
      action = function(ctx)
        ctx.send(vim.fn.keytrans(vim.fn['lexima#expand']('<S-TAB>', 'i')))
      end,
    })
  end

  local function cmdline_add(keys, recipe)
    insx.add(keys, recipe, { mode = 'c' })
  end

  do -- handle <Tab> in cmdline
    cmdline_add('<Tab>', {
      enabled = cmp_visible,
      action = function()
        local cmp = require 'cmp'
        cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
      end,
    })
    cmdline_add('<Tab>', {
      enabled = pum_visible,
      action = function(ctx)
        vim.fn['pum#map#insert_relative'](1)
        ctx.send '<Cmd>redraw<CR>'
      end
    })
    cmdline_add('<Tab>', {
      enabled = wilder_visible,
      action = function()
        vim.fn['wilder#next']()
      end
    })
    cmdline_add('<Tab>', {
      priority = -1,
      action = function(ctx)
        ctx.send '<Tab>'
      end
    })
  end

  do -- handle <S-Tab> in cmdline
    cmdline_add('<S-Tab>', {
      enabled = cmp_visible,
      action = function()
        local cmp = require 'cmp'
        cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
      end,
    })
    cmdline_add('<S-Tab>', {
      enabled = pum_visible,
      action = function(ctx)
        vim.fn['pum#map#insert_relative'](-1)
        ctx.send '<Cmd>redraw<CR>'
      end
    })
    cmdline_add('<S-Tab>', {
      enabled = wilder_visible,
      action = function()
        vim.fn['wilder#previous']()
      end
    })
    cmdline_add('<S-Tab>', {
      priority = -1,
      action = function(ctx)
        ctx.send '<S-Tab>'
      end
    })
  end

  do -- handle <C-g> in cmdline
    cmdline_add('<C-g>', {
      enabled = cmp_visible,
      action = function()
        local cmp = require 'cmp'
        cmp.close()
      end,
    })
    cmdline_add('<C-g>', {
      enabled = pum_visible,
      action = function()
        vim.fn['pum#map#cancel']()
      end
    })
    cmdline_add('<C-g>', {
      enabled = wilder_visible,
      action = function()
        vim.fn['wilder#reject_completion']()
      end
    })
    cmdline_add('<C-g>', {
      priority = -1,
      action = function(ctx)
        ctx.send '<C-e>'
      end
    })
  end

  do -- handle <C-f> in cmdline
    cmdline_add('<C-f>', {
      enabled = cmp_visible,
      action = function(ctx)
        local cmp = require 'cmp'
        cmp.close()
        ctx.send '<C-f>'
      end,
    })
    cmdline_add('<C-f>', {
      enabled = pum_visible,
      action = function(ctx)
        vim.fn['pum#map#cancel']()
        ctx.send '<C-f>'
      end
    })
    cmdline_add('<C-f>', {
      priority = -1,
      action = function(ctx)
        ctx.send '<C-f>'
      end
    })
  end
end

return {
  setup = setup,
}
