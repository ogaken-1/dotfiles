--- buffer, mrw, filesを結合して表示する
local function smart_open()
  local fzf = require 'fzf-lua'
  local cwd = vim.fn.getcwd()
  local opts = {
    file_icons = true,
    color_icons = true,
    git_icons = true,
    cwd = cwd,
  }
  -- git statusの取得やiconのロードなど事前に済ませておく
  -- みたいな感じになってるぽい
  fzf.make_entry.preprocess(opts)
  local make_entry = function(path)
    return fzf.make_entry.file(path, opts)
  end
  fzf.fzf_exec(function(next)
    -- 同じ候補を2個表示するようなことはしない
    local seen = {}
    local function push_if_not_seen(path)
      path = vim.fn.fnamemodify(path, ':.')
      if not seen[path] then
        seen[path] = true
        next(make_entry(path))
      end
    end

    -- 1. 現在のbuflistを取得して表示
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_get_option_value('buflisted', { buf = bufnr }) then
        local path = vim.api.nvim_buf_get_name(bufnr)
        if path ~= '' and vim.fn.filereadable(path) == 1 and string.find(path, cwd, 1, true) then
          push_if_not_seen(path)
        end
      end
    end

    -- 2. MRWリストから取得して表示
    for _, path in ipairs(vim.fn['mr#filter'](vim.fn['mr#mrw#list'](), cwd)) do
      if not string.match(path, '.git/COMMIT_EDITMSG') then
        push_if_not_seen(path)
      end
    end

    -- 3. fdで取得して表示
    for _, path in ipairs(vim.fn.systemlist { 'fd', '.', cwd }) do
      push_if_not_seen(path)
    end
    next()
  end, {
    prompt = 'files > ',
    actions = {
      ['enter'] = fzf.actions.file_edit_or_qf,
      ['ctrl-x'] = fzf.actions.file_split,
      ['ctrl-v'] = fzf.actions.file_vsplit,
    },
    previewer = 'builtin',
    fzf_opts = {
      ['--multi'] = true,
    },
  })
end

return {
  'ibhagwan/fzf-lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  cmd = 'FzfLua',
  opts = {
    files = {
      actions = {
        ['ctrl-g'] = false,
      },
    },
    oldfiles = {
      cwd_only = true,
      include_current_session = true,
    },
  },
  keys = {
    '<Plug>(ff)',
    '<Plug>(lsp-references)',
    '<Plug>(lsp-implementations)',
  },
  init = function()
    local builtin_select = vim.ui.select
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function(...)
      vim.ui.select = builtin_select
      vim.cmd.FzfLua 'register_ui_select'
      vim.ui.select(...)
    end
  end,
  config = function(_, opts)
    require('fzf-lua').setup(opts)

    vim.keymap.set('n', '<Plug>(ff)f', smart_open)
    vim.keymap.set('n', '<Plug>(ff)b', '<Cmd>FzfLua buffers<CR>')
    vim.keymap.set('n', '<Plug>(ff)h', '<Cmd>FzfLua helptags<CR>')
    vim.keymap.set('n', '<Plug>(ff)/', '<Cmd>FzfLua lines<CR>')
    vim.keymap.set('n', '<Plug>(ff)?', '<Cmd>FzfLua live_grep<CR>')

    vim.keymap.set('n', '<Plug>(lsp-references)', '<Cmd>FzfLua lsp_references<CR>')
    vim.keymap.set('n', '<Plug>(lsp-implementations)', '<Cmd>FzfLua lsp_implementations<CR>')
  end,
}
