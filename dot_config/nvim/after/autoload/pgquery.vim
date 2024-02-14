function! pgquery#do() abort range
  const query = bufnr()
        \ ->bufname()
        \ ->getbufline(a:firstline, a:lastline)
        \ ->join()
  const rows = s:exec_query(query)
  new
  setlocal buftype=nofile
  setfiletype json
  call setline(1, rows->json_encode())
  if executable('jq')
    %!jq
  endif
endfunction

function! s:exec_query(query) abort
  call s:check_environment_variables()
  if denops#plugin#wait('pgquery')
    return
  endif
  return denops#request('pgquery', 'queryObject', [a:query])
endfunction

function! s:check_environment_variables() abort
  if $PGHOST->empty()
    throw '$PGHOST env var is required.'
  endif
  if $PGDATABASE->empty()
    throw '$PGDATABASE env var is required.'
  endif
  if $PGPORT->empty()
    throw '$PGPORT env var is required.'
  endif
  if $PGUSER->empty()
    throw '$PGUSER env var is required.'
  endif
  if $PGPASSWORD->empty()
    throw '$PGPASSWORD env var is required.'
  endif
endfunction
