local function pum_visible()
  return vim.fn.exists '*pum#visible' == 1 and
      vim.fn['pum#visible']()
end

local function wilder_visible()
  return 1 == vim.fn.exists '*wilder#in_context' and
      vim.fn['wilder#in_context']() == 1
end

local function vsnip_jumpable(count)
  return 1 == vim.fn.exists '*vsnip#jumpable' and
      1 == vim.fn['vsnip#jumpable'](count)
end

local function lexima_installed()
  return 1 == vim.fn.exists '*lexima#expand'
end

local setup = function()
  local insx = require 'insx'

  insx.add('<CR>', insx.compose {
    {
      enabled = pum_visible,
      action = function()
        vim.fn['pum#map#confirm']()
      end,
    },
    {
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
    },
    {
      priority = -1,
      enabled = lexima_installed,
      action = function(ctx)
        ctx.send(vim.fn.keytrans(vim.fn['lexima#expand']('<CR>', 'i')))
      end,
    },
  })

  insx.add('<C-n>', insx.compose {
    {
      enabled = function()
        return 1 == vim.fn.pumvisible()
      end,
      action = function(ctx)
        ctx.send '<C-n>'
      end,
    },
    {
      enabled = pum_visible,
      action = function()
        vim.fn['pum#map#insert_relative'](1)
      end,
    },
    {
      priority = -1,
      action = function()
        vim.fn['ddc#map#manual_complete']()
      end
    },
  })

  insx.add('<C-p>', insx.compose {
    {
      enabled = function()
        return 1 == vim.fn.pumvisible()
      end,
      action = function(ctx) ctx.send '<C-p>' end,
    },
    {
      enabled = pum_visible,
      action = function() vim.fn['pum#map#insert_relative'](-1) end,
    },
    {
      priority = -1,
      action = function()
        vim.fn['ddc#map#manual_complete']()
      end
    },
  })

  insx.add('<C-g>', insx.compose {
    {
      enabled = function()
        return 1 == vim.fn.pumvisible()
      end,
      action = function(ctx)
        ctx.send '<C-e>'
      end,
    },
    {
      enabled = pum_visible,
      action = function()
        vim.fn['pum#map#cancel']()
      end,
    },
    {
      priority = -1,
      action = function(ctx)
        ctx.send '<C-g>'
      end
    },
  })

  insx.add('<Tab>', insx.compose {
    {
      enabled = function()
        return vsnip_jumpable(1)
      end,
      action = function(ctx)
        ctx.send '<Plug>(vsnip-jump-next)'
      end,
    },
    {
      enabled = function()
        return vim.fn.exists '*UltiSnips#CanJumpForwards' == 1 and vim.fn['UltiSnips#CanJumpForwards']() == 1
      end,
      action = function(ctx)
        ctx.send '<Plug>(ultisnips-jump-next)'
      end,
    },
    {
      enabled = function()
        return vim.snippet.jumpable(1)
      end,
      action = function()
        vim.snippet.jump(1)
      end,
    },
    {
      priority = -1,
      enabled = lexima_installed,
      action = function(ctx)
        ctx.send(vim.fn.keytrans(vim.fn['lexima#expand']('<TAB>', 'i')))
      end,
    },
  })

  insx.add('<S-Tab>', insx.compose {
    {
      enabled = function()
        return vsnip_jumpable(-1)
      end,
      action = function(ctx)
        ctx.send '<Plug>(vsnip-jump-next)'
      end,
    },
    {
      enabled = function()
        return vim.fn.exists '*UltiSnips#CanJumpBackwards' == 1 and vim.fn['UltiSnips#CanJumpBackwards']() == 1
      end,
      action = function(ctx)
        ctx.send '<Plug>(ultisnips-jump-previous)'
      end,
    },
    {
      enabled = function()
        return vim.snippet.jumpable(-1)
      end,
      action = function()
        vim.snippet.jump(-1)
      end,
    },
    {
      priority = -1,
      enabled = lexima_installed,
      action = function(ctx)
        ctx.send(vim.fn.keytrans(vim.fn['lexima#expand']('<S-TAB>', 'i')))
      end,
    },
  })

  local function cmdline_add(keys, recipe)
    insx.add(keys, recipe, { mode = 'c' })
  end

  cmdline_add('<Tab>', insx.compose {
    {
      enabled = pum_visible,
      action = function(ctx)
        vim.fn['pum#map#insert_relative'](1)
        ctx.send '<Cmd>redraw<CR>'
      end
    },
    {
      enabled = wilder_visible,
      action = function()
        vim.fn['wilder#next']()
      end
    },
    {
      priority = -1,
      action = function(ctx)
        ctx.send '<C-z>'
      end
    }
  })

  cmdline_add('<S-Tab>', insx.compose {
    {
      enabled = pum_visible,
      action = function(ctx)
        vim.fn['pum#map#insert_relative'](-1)
        ctx.send '<Cmd>redraw<CR>'
      end
    },
    {
      enabled = wilder_visible,
      action = function()
        vim.fn['wilder#previous']()
      end
    },
    {
      enabled = function()
        return 1 == vim.fn.pumvisible()
      end,
      action = function(ctx)
        ctx.send '<S-Tab>'
      end,
    },
    {
      priority = -1,
      action = function(ctx)
        ctx.send '<C-z>'
      end
    }
  })

  cmdline_add('<C-g>', insx.compose {
    {
      enabled = pum_visible,
      action = function()
        vim.fn['pum#map#cancel']()
      end
    },
    {
      enabled = wilder_visible,
      action = function()
        vim.fn['wilder#reject_completion']()
      end
    },
    {
      priority = -1,
      action = function(ctx)
        ctx.send '<C-e>'
      end
    }
  })

  cmdline_add('<C-f>', insx.compose {
    {
      enabled = pum_visible,
      action = function(ctx)
        vim.fn['pum#map#cancel']()
        ctx.send '<C-f>'
      end
    },
    {
      priority = -1,
      action = function(ctx)
        ctx.send '<C-f>'
      end
    }
  })
end

return {
  setup = setup,
}
