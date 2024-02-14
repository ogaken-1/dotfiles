if !exists('*s:gd')
  function! s:gd(word) abort
    " autoload function/variable
    if a:word =~# '^\%(\w\+#\)\+'
      const fname = a:word
            \ ->matchstr('^\%(\w\+#\)\+')
            \ ->substitute('#', '/', 'g')
            \ ->substitute('/$', '', '')
            \ ->printf('autoload/%s.vim')
      const files = nvim_get_runtime_file(fname, v:true)
      if files->len() ==# 1
        exe 'edit' files[0]
        call search(a:word->printf('\Vfunction!\?\s\zs\<%s\>'))
        let @/ = a:word->printf('\V\<%s\>')
        return
      endif
    endif

    normal! gd
  endfunction
endif

nnoremap <buffer> gd <Cmd>call <SID>gd(expand('<cword>'))<CR>
