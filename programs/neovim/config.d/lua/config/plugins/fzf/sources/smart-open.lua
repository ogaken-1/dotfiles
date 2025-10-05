local is_loaded = vim.api.nvim_buf_is_loaded
local function is_listed(bufnr)
  return vim.api.nvim_get_option_value('buflisted', { buf = bufnr })
end
local function is_file(path)
  return path ~= '' and vim.fn.filereadable(path) == 1
end
local function first_includes_second(a, b)
  return string.find(b, a, 1, true)
end
local function list_bufs()
  local bufs = {}
  local cwd = vim.fn.getcwd()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if is_loaded(bufnr) and is_listed(bufnr) then
      local path = vim.api.nvim_buf_get_name(bufnr)
      if is_file(path) and first_includes_second(cwd, path) then
        table.insert(bufs, #bufs, path)
      end
    end
  end
  return bufs
end
local function mrw_paths()
  local cwd = vim.fn.getcwd()
  local mrw_list = vim.fn['mr#filter'](vim.fn['mr#mrw#list'](), cwd)
  return vim
    .iter(mrw_list)
    :filter(function(path)
      return not string.match(path, '.git/COMMIT_EDITMSG')
    end)
    :totable()
end
-- 同じ候補を2個表示するようなことはしない
local function create_duplicate_checker()
  local seen_paths = {}
  return {
    try_add = function(path)
      if seen_paths[path] then
        return false
      end
      seen_paths[path] = true
      return true
    end,
  }
end
local function collect_vim_managed_entries(duplicate_checker)
  local entries = {}

  -- 1. 現在のbuflistを取得して表示
  for _, path in ipairs(list_bufs()) do
    path = vim.fn.fnamemodify(path, ':.')
    if duplicate_checker.try_add(path) then
      table.insert(entries, path)
    end
  end

  -- 2. MRWリストから取得して表示
  for _, path in ipairs(mrw_paths()) do
    path = vim.fn.fnamemodify(path, ':.')
    if duplicate_checker.try_add(path) then
      table.insert(entries, path)
    end
  end

  return entries
end

--- buffer, mrw, filesを結合して表示する
local function smart_open()
  local fzf = require 'fzf-lua'
  local os_cmd = require 'config.os_cmd'

  local cwd = vim.fn.getcwd()
  local opts = {
    file_icons = true,
    color_icons = true,
    git_icons = true,
    cwd = cwd,
  }
  -- git statusの取得やiconのロードなど事前に済ませておく
  -- みたいな感じになってるぽい
  vim.schedule(function()
    fzf.make_entry.preprocess(opts)
  end)
  local function make_entry(path)
    return fzf.make_entry.file(path, opts)
  end
  local duplicate_checker = create_duplicate_checker()
  -- vim側で用意できるものは先に作っておく
  -- fzf_execの中でインラインでやるとコマンド実行してからfzfの画面が
  -- 表示されるまでのラグがちょっと大きくなって体験が落ちる
  local entries_managed_by_vim = collect_vim_managed_entries(duplicate_checker)
  fzf.fzf_exec(function(next)
    for _, entry in ipairs(entries_managed_by_vim) do
      next(make_entry(entry))
    end
    -- 3. fdで取得して表示
    coroutine.wrap(function()
      local co = coroutine.running()
      for path in os_cmd.iter({ 'fd', '--hidden', '.', cwd }, { cwd = cwd }) do
        path = vim.fn.fnamemodify(path, ':.')
        if duplicate_checker.try_add(path) then
          next(make_entry(path), function()
            if coroutine.status(co) == 'suspended' then
              coroutine.resume(co)
            end
          end)
          coroutine.yield()
        end
      end
      next()
    end)()
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

return smart_open
