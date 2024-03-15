---@param node? TSNode
---@param node_type string
---@return boolean
local function in_node_recursive(node, node_type)
  return (node ~= nil) and ((node:type() == node_type) or in_node_recursive(node:parent(), node_type))
end
---@param node_type string
---@return boolean
local function in_node(node_type)
  return in_node_recursive(vim.treesitter.get_node(), node_type)
end
---@param lines string|string[]
---@return insx.Recipe
local function snippet_recipe(lines)
  if type(lines) == 'table' then
    lines = table.concat(lines, '\n')
  end
  return {
    action = function(ctx)
      ctx.send '<C-w>'
      vim.snippet.expand(lines)
    end,
  }
end
local function insx_mod()
  local insx = require 'insx'
  return {
    add = insx.add,
    with = insx.with,
    auto_pair = require 'insx.recipe.auto_pair',
    delete_pair = require 'insx.recipe.delete_pair',
    jump_next = require 'insx.recipe.jump_next',
    pair_spacing = require 'insx.recipe.pair_spacing',
    fast_break = require 'insx.recipe.fast_break',
    esc = insx.helper.regex.esc,
  }
end
local left = '<C-g>U<Left>'
local function denippet()
  local insx = insx_mod()
  insx.add(',', {
    enabled = function()
      return vim.fn['denippet#expandable']()
    end,
    action = function(ctx)
      ctx.send '<Plug>(denippet-expand)'
    end,
  })
  insx.add('<Tab>', {
    enabled = function()
      return vim.fn['denippet#jumpable'](1)
    end,
    action = function(ctx)
      ctx.send '<Plug>(denippet-jump-next)'
    end,
  })
end
local function builtin_snippet()
  local insx = insx_mod()
  insx.add('<Tab>', {
    enabled = function()
      return vim.snippet.jumpable(1)
    end,
    action = function()
      vim.snippet.jump(1)
    end,
  })
end
local function cmp1()
  local insx = insx_mod()
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
local function c_sharp()
  local insx = insx_mod()
  ---@param ctx insx.Context
  local function is_cs(ctx)
    return ctx.filetype == 'cs' or ctx.filetype == 'razor'
  end
  insx.add(';', {
    enabled = function(ctx)
      return is_cs(ctx) and ctx.after() ~= ''
    end,
    action = function(ctx)
      local row = ctx.row()
      ctx.move(row, #vim.fn.getline(row + 1))
      ctx.send ';'
    end,
  })
  insx.add('g', {
    enabled = function(ctx)
      return is_cs(ctx) and ctx.match [[{\s*\%#\s*}]]
    end,
    action = function(ctx)
      ctx.send('get;' .. left)
    end,
  })
  insx.add('<Tab>', {
    enabled = function(ctx)
      return is_cs(ctx) and ctx.match [[{\s*get\%#;\s*}]]
    end,
    action = function(ctx)
      ctx.move(ctx.row(), ctx.col() + 1)
    end,
  })
  insx.add('s', {
    enabled = function(ctx)
      return is_cs(ctx) and ctx.match [=[{\s*\(get[^;]*;\s*\)\?\%#\s*}]=]
    end,
    action = function(ctx)
      ctx.send('set;' .. left)
    end,
  })
  insx.add('i', {
    enabled = function(ctx)
      return is_cs(ctx) and ctx.match [=[{\s*\(get[^;]*;\s*\)\?\%#\s*}]=]
    end,
    action = function(ctx)
      ctx.send('init;' .. left)
    end,
  })
  insx.add('<Tab>', {
    enabled = function(ctx)
      return is_cs(ctx) and ctx.match [=[{\s*\(get[^;]*;\s*\)\?\(set\|init\)[^;]*\%#;\s*}]=]
    end,
    action = function(ctx)
      ctx.move(ctx.row(), ctx.col() + vim.regex([[;\s*}\zs]]):match_str(ctx.after()))
    end,
  })
  for _, word in ipairs { 'if', 'for', 'while' } do
    insx.add('<Space>', {
      enabled = function(ctx)
        return (ctx.filetype == 'cs' or ctx.filetype == 'razor') and (ctx.match([[\<]] .. word .. [[\%#(\@!]]))
      end,
      action = function(ctx)
        ctx.send('<Space>()' .. left)
      end,
    })
  end
  insx.add(
    '<Space>',
    insx.with(
      snippet_recipe {
        'foreach (var ${2:item} in ${1:collection})',
        '{',
        '\t$0',
        '}',
      },
      {
        insx.with.filetype { 'cs', 'razor' },
        insx.with.match [[\<@\?foreach\%#]],
      }
    )
  )
  insx.add('<Space>', {
    enabled = function(ctx)
      if ctx.filetype ~= 'cs' and ctx.filetype ~= 'razor' then
        return false
      end
      return (ctx.match [=[\w\((\|,\s*\)\(out\|await\|new\)\@!\w\+\%#]=])
        and (ctx.filetype == 'razor' or in_node 'argument_list')
    end,
    action = function(ctx)
      ctx.send '<Space>=><Space>'
    end,
  })
  insx.add(
    '<Space>',
    insx.with(snippet_recipe 'var $2 = $1;$0', {
      insx.with.filetype { 'cs', 'razor' },
      insx.with.match [[^\s*v\%#$]],
    })
  )
  insx.add(
    '<Space>',
    insx.with(snippet_recipe 'var ${1:func} = (${2:args}) => $0;', {
      insx.with.filetype { 'cs', 'razor' },
      insx.with.match [[^\s*vf\%#$]],
    })
  )
end
local function common()
  local insx = insx_mod()

  -- '(>\%#)expr'.key('>') → '(expr)\%#'
  insx.add('>', {
    enabled = function(ctx)
      return ctx.match [[(>\%#)]]
    end,
    action = function(ctx)
      ctx.remove [[>\%#)]]
      ---@type string
      local line = ctx.text()
      if vim.fn.match(line, [[;$]]) ~= -1 then
        ctx.move(ctx.row(), #line - 1)
      else
        ctx.move(ctx.row(), #line)
      end
      ctx.send ')'
    end,
  })

  for _, pair in ipairs {
    { '(', ')' },
    { '{', '}' },
    { '[', ']' },
  } do
    local bra, ket = unpack(pair)
    insx.add(
      bra,
      insx.auto_pair {
        open = bra,
        close = ket,
      }
    )
    insx.add(
      '<BS>',
      insx.delete_pair {
        open_pat = insx.esc(bra),
        close_pat = insx.esc(ket),
      }
    )
    insx.add(
      '<Tab>',
      insx.jump_next {
        jump_pat = {
          [[\%#\s*]] .. insx.esc(ket) .. [[\zs]],
        },
      }
    )
    insx.add(
      '<Space>',
      insx.pair_spacing.increase {
        open_pat = insx.esc(bra),
        close_pat = insx.esc(ket),
      }
    )
    insx.add(
      '<BS>',
      insx.pair_spacing.decrease {
        open_pat = insx.esc(bra),
        close_pat = insx.esc(ket),
      }
    )
    insx.add(
      '<CR>',
      insx.fast_break {
        open_pat = insx.esc(bra),
        close_pat = insx.esc(ket),
        arguments = true,
        html_attrs = true,
        html_tags = true,
      }
    )
  end

  for _, pair in ipairs {
    { '"', '"' },
    { '\'', '\'' },
    { '`', '`' },
  } do
    local open_char, close_char = unpack(pair)
    insx.add(
      open_char,
      insx.auto_pair {
        open = open_char,
        close = close_char,
      }
    )
    insx.add(
      '<BS>',
      insx.delete_pair {
        open_pat = insx.esc(open_char),
        close_pat = insx.esc(close_char),
      }
    )
    insx.add(
      '<Tab>',
      insx.jump_next {
        jump_pat = {
          [[\%#]] .. insx.esc(close_char) .. [[\zs]],
        },
      }
    )
  end
end
local function lua()
  local insx = insx_mod()
  insx.add('>', {
    enabled = function(ctx)
      return (ctx.filetype == 'lua')
        and (vim.treesitter.get_node({ pos = { ctx.row(), ctx.col() } }):type() == 'string')
        and (ctx.match [[<Cmd\%#]])
    end,
    action = function(ctx)
      ctx.send('><lt>CR>' .. (left:rep(#'<CR>')))
    end,
  })
end
return {
  'hrsh7th/nvim-insx',
  event = 'InsertEnter',
  config = function()
    local setups = {
      denippet,
      builtin_snippet,
      cmp1,
      c_sharp,
      common,
      lua,
    }
    for _, fn in ipairs(setups) do
      fn()
    end
  end,
}
