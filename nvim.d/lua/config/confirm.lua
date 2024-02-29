return function(prompt)
  local input = vim.fn.input { prompt = prompt .. ' [Y/n] ' }
  return vim.regex([=[^[Yy]\(es\)\?]=]):match_str(input)
end
