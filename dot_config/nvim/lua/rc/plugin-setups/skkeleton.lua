---@param types string[]
---@return string[]
local function get_dictionaries(types)
  local files = vim.system({ 'fd', 'SKK-JISYO' }, { cwd = '/usr/share/skk' }):wait()
  local dictionaries = vim
    .iter(files)
    :filter(function(path)
      return vim.list_contains(types, vim.fn.fnamemodify(path, ':e'))
    end)
    :totable()
  return dictionaries
end

local function setup()
  vim.keymap.set({ 'i', 'c' }, '<C-j>', '<Plug>(skkeleton-enable)')
  vim.fn['skkeleton_azik#setup'] {
    keys = {
      katakana = '[',
    },
  }
  local skkDataDir = vim.fs.joinpath(vim.env['XDG_DATA_HOME'], 'skk')
  local databasePath = vim.fs.joinpath(vim.fn.stdpath 'cache', 'skkeleton', 'jisyo.db')
  vim.fn['skkeleton#register_keymap']('henkan', 'p', 'purgeCandidate')
  vim.fn['skkeleton#config'] {
    eggLikeNewline = true,
    globalDictionaries = get_dictionaries { 'L', 'geo', 'jinmei', 'emoji' },
    userJisyo = vim.fs.joinpath(skkDataDir, 'user-jisyo'),
    databasePath = databasePath,
    completionRankFile = vim.fs.joinpath(skkDataDir, 'rank.json'),
    kanaTable = 'azik',
    immediatelyCancel = false,
    registerConvertResult = true,
  }
end

vim.api.nvim_create_autocmd('User', {
  group = 'VimRc',
  once = true,
  pattern = 'DenopsPluginPost:skkeleton',
  callback = setup,
})
