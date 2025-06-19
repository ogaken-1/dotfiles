function config#gin#log#do(fn) range abort
  const entries = s:parse(getline(a:firstline, a:lastline)).entries
  call call('s:'..a:fn, [entries])
endfunction

function s:diffqf(entries) abort
  if empty(a:entries)
    return
  endif
  call assert_equal(v:t_list, type(a:entries), 'entries must be a list')
  const commits = a:entries->deepcopy()->map({ _, entry -> entry.commit })
  defer execute('copen')
  if commits->len() ==# 1
    let diff_start = s:previous_commit(commits[0])
    let diff_end = commits[0]
  else
    " rangeをvisualで与えてコミットの一覧を取得したとき、処理順で早いものは
    " 画面で上方に表示されている → 新しいコミット
    " 処理順で後ろのものは画面で下方に表示されている → 古いコミット
    " という前提のもと、commitsの最後のindexにあるもの → commitsの最初のindexにあるもの
    " というdiffの取り方をする
    let diff_start = s:previous_commit(commits[-1])
    let diff_end = commits[0]
  endif
  const modified_files = systemlist(['git', 'diff', '--name-only', diff_start .. '..' .. diff_end])
  if empty(modified_files)
    call setqflist([])
    return
  endif
  const project = gin#util#worktree()
  const qf_items = modified_files->deepcopy()->map({ _, filename -> #{
        \ module: 'gin diff',
        \ text: filename,
        \ filename: s:gindiff_bufname(project, diff_start, diff_end, filename),
        \}})
  call setqflist(qf_items)
endfunction

function s:gindiff_bufname(project, start_commit, last_commit, file) abort
  return printf(
        \ 'gindiff://%s;commitish=%s..%s#[%%22%s%%22]',
        \ a:project,
        \ a:start_commit,
        \ a:last_commit,
        \ a:file
        \ ) 
endfunction

" lambdalisue/vim-gin のリポジトリよりコードを拝借 & Vim scriptへポート
" https://github.com/lambdalisue/vim-gin/blob/main/LICENSE
const s:line_pattern = '^\%([ *\|\\\/+\-=<>]*\|[ *\|\\\/+\-=<>]*commit \%(+\-=<> \)\?\)\?\([a-fA-F0-9]\+\)\>'
function s:parse(contents) abort
  const entries = a:contents
        \ ->map({ _, line -> matchlist(line, s:line_pattern) })
        \ ->filter({ _, matches -> !empty(matches) })
        \ ->map({ _, matches -> #{ commit: matches[1] } })
  return #{ entries: entries }
endfunction

function s:previous_commit(commit) abort
  return system(['git', 'rev-parse', a:commit..'^'])[:(a:commit->len() - 1)]
endfunction
