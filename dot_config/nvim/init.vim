lua vim.loader.enable()

" nvim -u init.vim で起動すると
" $MYVIMRCがセットされないので一部の設定が機能しなくなる
let $MYVIMRC = $MYVIMRC ?? expand('<sfile>:p')
const s:here = $MYVIMRC->fnamemodify(':h')

augroup VimRc
  autocmd!
augroup END

" yankした範囲をハイライトする
autocmd VimRc TextYankPost * silent! lua vim.highlight.on_yank()

lua require('rc.dotenv').setup()

lua require('rc.nvim-lsp').setup()

let g:dein#inline_vimrcs = [
      \ s:here .. '/startup.vim',
      \ s:here .. '/global.lua',
      \ s:here .. '/commands.vim',
      \ s:here .. '/options.vim',
      \ s:here .. '/keymaps.vim',
      \ s:here .. '/tabstop.lua',
      \ ]

execute 'source' s:here .. '/dein.vim'

lua require('rc.diagnostics')
