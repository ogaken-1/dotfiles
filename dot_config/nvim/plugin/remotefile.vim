if s:->get('loaded', v:false)
  finish
endif
let s:loaded = v:true

augroup remotefile
  autocmd!
  autocmd BufReadCmd https://* call remotefile#read(expand('<amatch>'))
augroup END
