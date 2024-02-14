return {
  name = 'cmdline',
  options = {
    matchers = { 'matcher_fuzzy' },
    sorters = { 'sorter_fuzzy' },
    converters = { 'converter_fuzzy' },
    ignoreCase = true,
    minAutoCompleteLength = 1,
    keywordPattern = [=[[a-zA-Z0-9#\_]+]=],
  },
}
