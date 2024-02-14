setl iskeyword+=:

if !exists('*s:gd')
  function! s:gd(word) abort
    const defcmd = '\%(function!\?\|let\|const\)'
    " autoload function
    if a:word =~# '^\%(\w\+#\)\+'
      const fname = a:word
            \ ->matchstr('^\%(\w\+#\)\+')
            \ ->substitute('#', '/', 'g')
            \ ->substitute('/$', '', '')
            \ ->printf('autoload/%s.vim')
      const files = fname->globpath(&rtp, v:true, v:true)
      if files->len() ==# 1
        exe 'edit' files[0]
        call search(a:word->printf('\V'..defcmd..'\s\zs\<%s\>'))
        let @/ = a:word->printf('\V\<%s\>')
        return
      endif
    elseif a:word =~# 's:\w\+'
      call cursor(1, 1)
      call search(a:word->printf('\V'..defcmd..'\s\zs\<%s\>'))
      let @/ = a:word->printf('\V\<%s\>')
      return
    endif

    normal! gd
    let @/ = a:word->printf('\V\<%s\>')
  endfunction
endif

nnoremap <buffer> gd <Cmd>call <SID>gd(expand('<cword>'))<CR>
