function! remotefile#read(url) abort
  if denops#plugin#wait('remotefile')
    return
  endif
  const content = denops#request('remotefile', 'getContent', [a:url])
  execute 'do' 'BufReadPre' a:url
  const bufnr = bufadd(a:url)
  call setbufline(bufnr, '$', content)
  execute 'do' 'BufReadPost' a:url
endfunction
