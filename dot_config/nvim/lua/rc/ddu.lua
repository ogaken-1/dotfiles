---@param action string
---@return function
local function uiAction(action)
  return function()
    vim.fn['ddu#ui#do_action'](action)
  end
end

---@param action string
---@param params? table
---@return function
local function itemAction(action, params)
  return function()
    vim.fn['ddu#ui#do_action']('itemAction', {
      name = action,
      params = params,
    })
  end
end

local function multiActions(actions)
  return function()
    vim.fn['ddu#ui#multi_actions'](vim
      .iter(actions)
      :map(function(action)
        if type(action) == 'table' then
          return action
        else
          return { action }
        end
      end)
      :totable())
  end
end

---@param bufnr integer
---@param pattern? string
---@return string|nil
local function find_root(bufnr, pattern)
  pattern = pattern or '.git'
  local path
  if vim.api.nvim_get_option_value('buftype', { buf = bufnr }) == '' then
    local root = vim.fs.find(pattern, {
      upward = true,
      type = 'directory',
      path = vim.api.nvim_buf_get_name(bufnr),
      stop = vim.uv.os_homedir(),
    })
    if #root == 0 then
      path = nil
    else
      path = vim.fn.fnamemodify(vim.fs.dirname(root[1]) or root[1], ':p')
    end
  else
    path = nil
  end
  return path
end

---A wrapper of vim.keymap.set()
---@param lhs string
---@param rhs string|function
---@param opts? table
local function nmap(lhs, rhs, opts)
  vim.keymap.set('n', lhs, rhs, opts)
end

---@enum DduActionFlags
local actionFlags = {
  None = 0,
  RefreshItems = 1,
  Redraw = 2,
  Persist = 4,
  RestoreCursor = 8,
}

---@class DduCustomActionDefinition
---@field type 'kind'|'source'|'ui'
---@field name string
---@field actionName string
---@field func fun(args: any): DduActionFlags

---@param config string|table
---@return table
local function normalize_config(config)
  -- config is source name
  if type(config) == 'string' then
    return {
      resume = false,
      name = 'default',
      sources = {
        {
          name = config,
        },
      },
    }
    -- config is arguments of ddu#start
  elseif type(config) == 'table' then
    -- sourceの指定は ddu.start { 'file' } みたいにできるようにする
    local normalizedConfig = {}
    for k, v in pairs(config) do
      if type(k) == 'number' then
        normalizedConfig.sources = normalizedConfig.sources or {}
        table.insert(normalizedConfig.sources, { name = v })
      else
        normalizedConfig[k] = v
      end
    end

    return vim.tbl_deep_extend('keep', normalizedConfig, {
      resume = false,
      name = 'default',
    })
  end

  return {}
end

local ddu = {}

function ddu.notify_window_size()
  local lines = vim.opt.lines:get()
  local height, row = math.floor(lines * 0.8), math.floor(lines * 0.1)
  local columns = vim.opt.columns:get()
  local width, col = math.floor(columns * 0.8), math.floor(columns * 0.1)

  local previewSplit, previewHeight, previewWidth
  if columns < 200 then
    previewSplit = 'horizontal'
    previewHeight = math.floor(height / 2)
    previewWidth = width
  else
    previewSplit = 'vertical'
    previewHeight = height
    previewWidth = math.floor(width / 2)
  end

  vim.fn['ddu#custom#patch_global'] {
    uiParams = {
      ff = {
        winHeight = height,
        winRow = row,
        winWidth = width,
        winCol = col,
        previewWidth = previewWidth,
        previewHeight = previewHeight,
        previewSplit = previewSplit,
      },
    },
  }
end

---@param config string|table
function ddu.start(config)
  vim.fn['ddu#start'](normalize_config(config))
end

---@param config string|table
function ddu.get_start_func(config)
  return function()
    ddu.start(config)
  end
end

---@param def DduCustomActionDefinition
---@return nil
function ddu.add_custom_action(def)
  vim.fn['ddu#custom#action'](def.type, def.name, def.actionName, def.func)
end

function ddu.setup()
  ddu.add_custom_action {
    type = 'kind',
    name = 'file',
    actionName = 'openProject',
    func = function(args)
      if #args.items == 0 then
        return actionFlags.None
      end
      local item = args.items[1]
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'ddu-ff',
        once = true,
        callback = function(ctx)
          local wins = vim
            .iter(vim.api.nvim_tabpage_list_wins(0))
            :filter(function(win)
              return vim.api.nvim_win_get_buf(win) == ctx.buf
            end)
            :totable()

          if #wins == 0 then
            return
          end
          local win = wins[1]

          vim.wo[win].winbar = item.action.path
        end,
      })
      vim.fn['ddu#start'] {
        sources = {
          {
            name = 'file_external',
            params = {
              cmd = { 'git', 'ls-files', '-co', '--exclude-standard' },
            },
            options = {
              path = item.action.path,
            },
          },
        },
      }
      return actionFlags.None
    end,
  }

  vim.fn['ddu#custom#load_config'](vim.fs.joinpath(vim.env.DEIN_CONFIG_DIR, 'ddu.ts'))

  vim.api.nvim_create_autocmd('VimResized', {
    group = 'VimRc',
    callback = ddu.notify_window_size,
  })

  ddu.notify_window_size()

  nmap('<Plug>(ddu-buffers)', ddu.get_start_func 'buffer')
  nmap('<Plug>(ddu-files)', '<Plug>(ddu-files:buf)')
  nmap('<Plug>(ddu-files:buf)', function()
    vim.fn['ddu#start'] {
      name = 'default',
      resume = false,
      sources = {
        {
          name = 'file_external',
          options = {
            path = find_root(vim.api.nvim_get_current_buf()),
          },
        },
      },
    }
  end, { desc = 'バッファのあるプロジェクトのルートディレクトリからfdした結果をddu' })
  nmap('<Plug>(ddu-files:cwd)', ddu.get_start_func 'file_external')
  nmap('<Plug>(ddu-rg)', function()
    vim.fn['ddu#start'] {
      sources = {
        {
          name = 'rg',
          options = {
            path = find_root(vim.api.nvim_get_current_buf()),
          },
        },
      },
    }
  end)
  nmap('<Plug>(ddu-lines)', ddu.get_start_func 'line')
  nmap(
    '<Plug>(ddu-mrw)',
    ddu.get_start_func {
      uiParams = {
        ff = {
          startFilter = false,
        },
      },
      sources = {
        {
          name = 'mr',
          params = {
            kind = 'mrw',
            current = true,
          },
        },
      },
    }
  )

  nmap('<Plug>(ddu-help_tags)', ddu.get_start_func 'help')

  nmap(
    '<Plug>(ddu-lsp_implementations)',
    ddu.get_start_func {
      uiParams = {
        ff = {
          startAutoAction = true,
          startFilter = false,
        },
      },
      sources = {
        {
          name = 'lsp_definition',
          params = {
            method = 'textDocument/implementation',
          },
        },
      },
    }
  )

  nmap(
    '<Plug>(ddu-lsp_references)',
    ddu.get_start_func {
      'lsp_references',
      uiParams = {
        ff = {
          startAutoAction = true,
          startFilter = false,
        },
      },
    }
  )

  nmap(
    '<Plug>(ddu-resume)',
    ddu.get_start_func {
      resume = true,
      name = 'default',
      uiParams = {
        ff = {
          startFilter = false,
        },
      },
    }
  )

  nmap(
    '<Plug>(ddu-config_files)',
    ddu.get_start_func {
      'file_external',
      sourceOptions = {
        file_external = {
          path = vim.fs.joinpath(vim.env.XDG_DATA_HOME, 'chezmoi'),
        },
      },
    }
  )

  vim.api.nvim_create_user_command('DduPlugins', ddu.get_start_func 'dein', {})
  vim.api.nvim_create_user_command('DduGhq', ddu.get_start_func 'ghq', {})
  vim.api.nvim_create_user_command('DduDenoModules', ddu.get_start_func 'deno_module', {})

  vim.api.nvim_create_autocmd('FileType', {
    group = 'VimRc',
    pattern = 'ddu-ff',
    desc = 'Setup keymaps of ddu-ff',
    callback = function(ctx)
      vim.keymap.set_table {
        mode = 'n',
        opts = {
          buffer = ctx.buf,
        },
        maps = {
          { '<CR>', uiAction 'itemAction' },
          { 'i', uiAction 'openFilterWindow' },
          { 'q', uiAction 'quit' },
          { 'd', itemAction 'trash' },
          { '<SPACE>', uiAction 'toggleSelectItem', { nowait = true } },
          { 'a', uiAction 'chooseAction' },
          { '<C-Space>', uiAction 'toggleAllItems' },
          { 'c', multiActions { 'toggleAllItems', { 'itemAction', { name = 'quickfix' } } } },
          { 'p', uiAction 'toggleAutoAction' },
          { 'l', uiAction 'expandItem' },
          { 'h', uiAction 'collapseItem' },
          { '<<', itemAction 'add' },
          { 'pp', itemAction 'patch' },
        },
      }

      vim.wo.cursorline = true
    end,
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = 'VimRc',
    pattern = 'ddu-ff-filter',
    desc = 'Setup keymaps of ddu-ff-filter',
    callback = function(ctx)
      vim.keymap.set('i', '<CR>', function()
        vim.cmd.stopinsert()
        vim.fn['ddu#ui#do_action'] 'closeFilterWindow'
      end, { buffer = ctx.buf })
      vim.keymap.set('n', '<CR>', uiAction 'closeFilterWindow', { buffer = ctx.buf })
      vim.keymap.set('n', 'q', uiAction 'quit', { buffer = ctx.buf })
    end,
  })

  vim.keymap.set(
    'n',
    '<Plug>(lsp-codeAction)',
    ddu.get_start_func {
      'lsp_codeAction',
      name = '_',
      uiParams = {
        ff = {
          startAutoAction = true,
          startFilter = false,
        },
      },
    }
  )

  vim.keymap.set('n', '<Plug>(git-status)', function()
    vim.fn['ddu#start'] {
      sources = {
        {
          name = 'git_status',
          options = {
            path = vim.fn.expand '%',
          },
        },
      },
      uiParams = {
        ff = {
          startAutoAction = true,
        },
      },
    }
  end)
end

return ddu
