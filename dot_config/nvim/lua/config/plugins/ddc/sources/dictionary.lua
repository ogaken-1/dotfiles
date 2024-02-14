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
  },
}
