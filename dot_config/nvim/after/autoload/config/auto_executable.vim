" Automatically applies executable permissions upon BufWritePost if the
" file begins with shebang.

augroup auto_executable
  autocmd!
augroup END

function! s:ensure_executable(fname) abort
  if !a:fname->filereadable()
    return
  endif
  if a:fname->getfperm() =~# 'x'
    return
  endif
  if '#!' ==# a:fname->getbufoneline(1)[0:1]
    const prompt = $'Do you want apply executable permission to {a:fname->fnamemodify(':.')} ? [Y/n] '
    const input = input(#{
          \ prompt: prompt,
          \ cancelreturn: 'no',
          \})
    if input =~? '^y\%[es]$'
      call setfperm(a:fname, 'rwxr-xr-x')
      echomsg 'Set executable permission to ' .. a:fname
    endif
  endif
endfunction

function! config#auto_executable#enable() abort
  if get(b:, 'auto_executable_enabled', 0)
    return
  endif
  let b:auto_executable_enabled = 1

  autocmd auto_executable BufWritePost <buffer>
        \ call <SID>ensure_executable(expand('<amatch>'))
endfunction

