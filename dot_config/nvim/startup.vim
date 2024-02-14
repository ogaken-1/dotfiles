if v:vim_did_enter
  finish
endif

" 起動前にfiletype系のスクリプトを読み込む必要はないので無効化する
" NOTE: filetype offにしてても起動したらonになってる なんでかはわからん
filetype off
filetype plugin indent off
syntax off

augroup EnableFtPlugins
  autocmd!
  autocmd FileType * ++once filetype plugin indent on
  autocmd FileType * ++once syntax enable
augroup END

augroup EnableFtDetect
  autocmd!
  autocmd BufReadPre,BufNewFile * ++once filetype on
  autocmd BufNewFile * ++once filetype detect
  autocmd FileType * autocmd! EnableFtDetect
augroup END
