local os_cmd = require 'config.os_cmd'

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
  vim.schedule(function()
    fzf.make_entry.preprocess(opts)
  end)
  local function make_entry(path)
    return fzf.make_entry.file(path, opts)
  end
  fzf.fzf_exec(function(next)
    -- 同じ候補を2個表示するようなことはしない
    local seen = {}
    local function push_if_not_seen(path, resume)
      path = vim.fn.fnamemodify(path, ':.')
      if not seen[path] then
        seen[path] = true
        next(make_entry(path), resume)
        return true
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
    coroutine.wrap(function()
      local co = coroutine.running()
      for path in os_cmd.iter({ 'fd', '.', cwd }, { cwd = cwd }) do
        local added = push_if_not_seen(path, function()
          if coroutine.status(co) == 'suspended' then
            coroutine.resume(co)
          end
        end)
        if added then
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
