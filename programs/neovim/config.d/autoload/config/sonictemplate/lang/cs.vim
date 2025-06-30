function! config#sonictemplate#lang#cs#namespace() abort
  const file_path = expand('%:p')
  const dir_path = file_path->isdirectory()
        \ ? file_path
        \ : file_path->fnamemodify(':h')
  const csproj_path = dir_path->s:find_csproj()
  if csproj_path->empty()
    return dir_path->fnamemodify(':.:h')->s:to_ns()
  endif
  const root_namespace = csproj_path->s:root_namespace()
  const sub_namespace = csproj_path->s:sub_namespace(dir_path)
  return [root_namespace, sub_namespace]->join('.')
endfunction

function! config#sonictemplate#lang#cs#classname() abort
  return expand('%:t:r')
endfunction

function! s:find_csproj(path) abort
  if a:path ==# '/'
    return ''
  endif
  if a:path->isdirectory()
    for file in a:path->readdir({ name -> name->fnamemodify(':e') ==# 'csproj' })
      return [a:path, file]->join('/')
    endfor
  endif
  return a:path->fnamemodify(':h')->s:find_csproj()
endfunction

function! s:root_namespace(csproj_path) abort
  const content = a:csproj_path->readfile()->join('\n')
  const match = content->matchstr('\v\<RootNamespace[^>]*\>\zs[^<]+\ze\<\/RootNamespace\>')
  if !match->empty()
    return match
  endif
  return a:csproj_path->fnamemodify(':t:r')
endfunction

function! s:sub_namespace(csproj_path, file_path) abort
  const csproj_dir = a:csproj_path->fnamemodify(':h')
  const is_included = a:file_path[:(csproj_dir->len() - 1)] ==# csproj_dir
  if is_included
    const sub_path = a:file_path[csproj_dir->len():]
    return sub_path->s:to_ns()
  endif
  return a:file_path->fnamemodify(':.')->s:to_ns()
endfunction

function! s:to_ns(path) abort
  return a:path->substitute('^\W\+', '', '')->substitute('\/', '.', 'g')
endfunction
