local databasePath = vim.fs.joinpath(vim.fn.stdpath 'cache', 'ddc', 'dictionary.db')
if 0 == vim.fn.isdirectory(vim.fs.dirname(databasePath)) then
  vim.fn.mkdir(vim.fs.dirname(databasePath))
end

return {
  name = 'dictionary',
  options = {
    matchers = { 'matcher_fuzzy' },
    sorters = { 'sorter_fuzzy' },
    converters = { 'converter_fuzzy' },
    ignoreCase = true,
    mark = '[Dict]',
  },
  params = {
    paths = { '/usr/share/dict/words' },
    firstCaseInsensitive = true,
    -- yay -S wordnet-cli
    -- documentCommand = { 'wn', '{{word}}', '-over' },
    databasePath = databasePath,
  },
}
