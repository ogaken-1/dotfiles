let g:mapleader = "\<Space>"

" sh,vim,help,c以外の多くのftでは不要
nnoremap K <Nop>
call nvim_create_autocmd('FileType', #{
      \ pattern: ['bash', 'zsh', 'sh', 'vim', 'help', 'c', 'cpp', 'man'],
      \ group: 'VimRc',
      \ command: 'nnoremap <buffer> K K',
      \ })

" 空行でインサートを開始するときにインデントする
nnoremap <expr> a getline('.')->empty() ? '"_cc' : 'a'
nnoremap <expr> i getline('.')->empty() ? '"_cc' : 'i'

" Emacs-style key mappings (cmdline mode)
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
" <[AC]-[fb]>は使わない
" カーソルが一番左にあるときはgetcmdpos()は1を返す
" 'hello'[:0] => 'h' なので、カーソルがh|elloにあるとき(getcmdpos() == 2)で0になるようにする
" 1のときに -2 するとおかしいのでそこだけ対応する
cnoremap <C-k> <Cmd>call setcmdline(getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos() - 2])<CR>

" Fuzzy Finder
nnoremap <Space>ff <Plug>(ff-files)
nnoremap <Space>fc <Plug>(ff-config_files)
nnoremap <Space>fw <Plug>(ff-grep)
nnoremap <Space>fh <Plug>(ff-help_tags)
nnoremap <Space>fH <Plug>(ff-grep_help)
nnoremap <Space>fs <Plug>(ff-lines)
nnoremap <Space>fb <Plug>(ff-buffers)
nnoremap <Space>fn <Plug>(ff-resume)
nnoremap <Space>fz <Plug>(ff-mrw)
" <Space>f<Esc>の場合に<Space>が実行されるのを回避
nnoremap <Space>f <Nop>

" Git integrations
nnoremap <Space>aa <Plug>(git-status)
nnoremap <Space>ac <Plug>(git-commit)
nnoremap <Space>aC <Plug>(git-commit:amend)
nnoremap <Space>ah <Plug>(git-log)
nnoremap <Plug>(git-log) <Plug>(git-log:current)
nnoremap <Space>aH <Plug>(git-log:cbuf)
nnoremap <Space>ab <Plug>(git-branch)

nnoremap <Space>e <Plug>(filer-parent)
nnoremap <Space>E <Plug>(filer-worktree)

" <C-[pn]>による履歴の補完でも現在の入力をリスペクトしてほしい
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

inoremap <silent><expr> <C-w> (pumvisible() ? "\<C-e>" : '') .. "\<C-w>"
inoremap <silent><expr> <C-u> (pumvisible() ? "\<C-e>" : '') .. "\<C-u>"
autocmd User LeximaSetupDone ++once inoremap <silent><expr> <BS> (pumvisible() ? "\<C-e>" : '') .. lexima#expand('<LT>BS>', 'i')

nnoremap t <Nop>
nnoremap tc <Cmd>tabnew<CR>
nnoremap tq <Cmd>tabclose<CR>
nnoremap tp <Cmd>tabprevious<CR>
nnoremap tn <Cmd>tabnext<CR>

lua << EOF
vim.keymap.set({ 'n', 'x' }, '<Space>y', '"+y')
vim.keymap.set('n', '<Space>yy', '"+yy')
vim.keymap.set({ 'n', 'x' }, '<Space>p', '"+p')
EOF
