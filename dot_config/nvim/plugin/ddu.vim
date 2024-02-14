if g:->get('loaded_ddu', v:false)
  finish
endif
let g:loaded_ddu = v:true

function! s:complete(...) abort
  return denops#request('config', 'ddu:complete', [])
endfunction

function s:command(args) abort
  if denops#plugin#wait('config')
    return
  endif
  call denops#notify('config', 'ddu:exec', a:args)
endfunction

command -nargs=1 -complete=custom,s:complete Ddu call s:command([<f-args>])
