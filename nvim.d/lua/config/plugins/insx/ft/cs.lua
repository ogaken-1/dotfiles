return {
  add = function()
    local insx = require 'insx'
    local substitute = require 'insx.recipe.substitute'
    local u = require 'config.plugins.insx.utils'

    ---@param key string
    ---@param at string
    ---@param recipe insx.RecipeSource | fun(ctx: insx.Context) | string
    local function add(key, at, recipe)
      insx.add(key, insx.with(u.normalize(recipe), { insx.with.filetype { 'cs', 'razor' }, insx.with.match(at) }))
    end
    add(';', [[\%#$\@!]], function(ctx)
      local row = ctx.row()
      ctx.move(row, #vim.fn.getline(row + 1))
      ctx.send ';'
    end)
    do -- for auto property syntax
      local patterns = {
        no_accessors = [[{\s*\%#\s*}]],
        getter_body = [[{\s*get\%#;\s*}]],
        getter_completed = [=[{\s*\%(get[^;]*;\s*\)\?\%#\s*}]=],
        setter_body = [=[{\s*\%(get[^;]*;\s*\)\?\%(set\|init\)[^;]*\%#;\s*}]=],
      }
      add('g', patterns.no_accessors, 'get;' .. u.left)
      add('<Tab>', patterns.getter_body, function(ctx)
        ctx.move(ctx.row(), ctx.col() + 1)
      end)
      add('s', patterns.getter_completed, 'set;' .. u.left)
      add('i', patterns.getter_completed, 'init;' .. u.left)
      add('<Tab>', patterns.setter_body, function(ctx)
        ctx.move(ctx.row(), ctx.col() + vim.regex([[;\s*}\zs]]):match_str(ctx.after()))
      end)
    end
    add(
      '<Space>',
      [[\<for\%#(\@!]],
      u.snippet_recipe {
        'for (int ${1:i} = 0; $1 < ${2:collection.Count}; $1++)',
        '{',
        '\t$0',
        '}',
      }
    )
    for _, word in ipairs { 'if', 'while' } do
      add('<Space>', [[\<]] .. word .. [[\%#(\@!]], '<Space>()' .. u.left)
    end
    add('w', [[^\s*c\%#$]], u.snippet_recipe 'Console.WriteLine(\\$"{nameof(${1})}:\\t{$1}")')
    add(
      '<Space>',
      [[\<@\?foreach\%#]],
      u.snippet_recipe {
        'foreach (var ${2:item} in ${1:collection})',
        '{',
        '\t$0',
        '}',
      }
    )
    add('<Space>', [[^\s*vf\%#$]], u.snippet_recipe 'var ${1:func} = (${2:args}) => $0;')
    add('<Space>', [[^\s*v\%#$]], u.snippet_recipe 'var $2 = $1;$0')
    add('<Space>', [=[\w\((\|,\s*\)\(out\|await\|new\|ref\|static\)\@!\w\+\%#]=], {
      enabled = function(ctx)
        return (ctx.filetype == 'razor' or u.in_node 'argument_list')
      end,
      action = function(ctx)
        ctx.send '<Space>=><Space>'
      end,
      priority = 1,
    })
    -- fix typos of `await`
    for _, wai in ipairs { 'wia', 'iwa', 'awi' } do
      insx.add(
        't',
        insx.with(
          substitute {
            pattern = [[\<a]] .. wai .. [[\%#]],
            replace = [[await\%#]],
          },
          { insx.with.filetype { 'cs' } }
        )
      )
    end
    -- XML comment syntax
    insx.add(
      '/',
      insx.with(
        u.snippet_recipe {
          '/// <summary>',
          '/// $0',
          '/// </summary>',
        },
        {
          insx.with.filetype 'cs',
          insx.with.in_comment(true),
          insx.with.match [[^\s*\/\/\%#$]],
        }
      )
    )
    insx.add(
      '>',
      insx.with(
        substitute {
          pattern = [[<\(\w\+\).\{-}\%#]],
          replace = [[\0>\%#</\1>]],
        },
        {
          insx.with.filetype 'cs',
          insx.with.in_comment(true),
        }
      )
    )
    insx.add(
      '<BS>',
      insx.with(
        substitute {
          pattern = [[<\(\w\+\).\{-}>\%#</.\{-}>]],
          replace = [[\%#]],
        },
        {
          insx.with.filetype 'cs',
          insx.with.in_comment(true),
        }
      )
    )
  end,
}
