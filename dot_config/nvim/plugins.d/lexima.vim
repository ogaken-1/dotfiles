" hook_source {{{
function s:add_rules(shared, rules) abort
  call map(a:rules, { _, rule -> lexima#add_rule(a:shared->deepcopy()->extend(rule, 'error')) })
endfunction

call s:add_rules(
      \ #{ char: '<Tab>' },
      \ [
      \   #{ at: '\%#\s*\n\{,1}\s*)',   leave: ')' },
      \   #{ at: '\%#\s*\n\{,1}\s*]',   leave: ']' },
      \   #{ at: '\%#\s*\n\{,1}\s*}',   leave: '}' },
      \   #{ at: '\%#\s*\n\{,1}\s*"',   leave: '"' },
      \   #{ at: '\%#\s*\n\{,1}\s*''',  leave: "'" },
      \   #{ at: '\%#\s*\n\{,1}\s*`',   leave: '`' },
      \ ]
      \ )

call s:add_rules(
      \ #{ filetype: 'lua' },
      \ [
      \   #{ char: '<Tab>', at: '\%#\s*\n{,1}\s*end', leave: 'end' },
      \   #{ char: '<Tab>', at: 'function\(\s[a-zA-Z0-9\.\_:]\+\)\{,1}(.*\%#)', leave: ')', input_after: 'end' },
      \   #{ char: '<CR>', at: '\%#end', input_after: '<CR>' },
      \   #{ char: '<CR>', at: 'if\s.*\sthen\%#', input_after: '<CR>end' },
      \   #{ char: '<Space>', at: '\%#end', input_after: '<Space>' },
      \ ]
      \ )

call s:add_rules(
      \ #{ filetype: 'html' },
      \ [
      \   #{ char: '<Tab>', at: '\%#</\w\+>', leave: '>' },
      \   #{ char: '<CR>', at: '\%#<\w\+>', input_after: '<CR>' },
      \   #{ char: '>', at: '<\(\w\+\)\%(\s\+\w\+=\".\+\"\)*\%#', input_after: '</\1>', with_submatch: 1 },
      \   #{ char: '/', at: '<\(\w\+\)\(\s\+\w\+=\".\+\"\)*\%#', input: '>' },
      \   #{ char: '=', at: '\w\+\%#', input: '="', input_after: '"' },
      \ ]
      \ )

call s:add_rules(
      \ #{ filetype: ['cs', 'razor'] },
      \ [
      \   #{ char: '<Tab>', at: 'get\%( => [^;]\+\)*\%#;', leave: ';' },
      \   #{ char: '<Tab>', at: '\%(set\|init\)\%( => .\+\)*\%#; }', leave: '}' },
      \   #{ char: '<Tab>', at: '<\%([a-zA-Z0-9_\.]\+?\{,1}\)\%(,\s*[a-zA-Z0-9_\.]\+?\{,1}\)*>*\%#>', leave: '>' },
      \   #{ char: '<Space>', at: '\%(get\|set\|init\)\%#;', input: ' => ' },
      \   #{ char: 'd', at: '#if \%#', input: 'DEBUG' },
      \   #{ char: '<CR>', at: '^\s*#if\s\+.\+\%#', input_after: '<CR>#endif' },
      \   #{ char: '<BS>', at: '<\%#>', delete: '>' },
      \   #{ char: 'g', at: '{ \%# }', input: 'get', input_after: ';' },
      \   #{ char: 's', at: '{ get\%( => [^;]\+\)*; \%# }', input: 'set', input_after: ';' },
      \   #{ char: 'i', at: '{ get\%( => [^;]\+\)*; \%# }', input: 'init', input_after: ';' },
      \   #{ char: '<Space>', at: 'DbSet<\([0-9a-zA-Z<>_]\+\)> \w\+\%#', input: ' => Set<\1>();', with_submatch: 1 },
      \   #{ char: '<', at: '[a-zA-Z0-9_]\%#', input_after: '>' },
      \   #{ char: ';', at: '\%#.\+$', input: '<End>;', except: '\('..
      \     'for\s*([^)]*\%#)'..'\|'..
      \     '\%(get\|set\|init\)\%( => [^;]\+\)*\%#'..'\)'
      \   },
      \   #{ char: '<Space>', at: '\.\w\+(\%([^)]\+,\s\)*\<\%(new\|out\)\@!\w\+\%#)', input: '<Space>=><Space>' },
      \   #{ char: '$', except: '\%#"', input: '$"', input_after: '"' },
      \ ]
      \ )

call s:add_rules(
      \   #{ filetype: ['cs', 'typescript'] },
      \   [
      \     #{ char: '<Space>', except: '\%#(', at: '\%(if\|for\|while\|foreach\|switch\)\%#', input: '<Space>(', input_after: ')' },
      \   ]
      \ )

call s:add_rules(
      \ #{ filetype: 'razor' },
      \ [
      \   #{ char: '<Space>', except: '\%#(', at: '@\{,1}\<\%(if\|for\|while\|foreach\|switch\)\%#', input: '<Space>(', input_after: ')' },
      \   #{ char: '*', at: '@\%#', input_after: '*@' },
      \   #{ char: '<Space>', at: '@\*\%#\*@', input_after: '<Space>' },
      \   #{ char: '<BS>', at: '@\*\s\%#\s\*@', input: '<BS><DEL>' },
      \   #{ char: '<BS>', at: '@\*\%#\*@', input: '<BS><BS>', delete: '*@' },
      \   #{ char: '/', at: '<[^>]\+\%#', input: '/>' },
      \   #{ char: '>', at: '<\(\w\+\)[^>]*\%#', with_submatch: 1, input: '>', input_after: '</\1>' },
      \   #{ char: '<CR>', at: '\%#</', input: '<CR>', input_after: '<CR>' },
      \   #{ char: '<Tab>', at: '\%#\n\{,1}\s*</\w\+>', leave: '>' },
      \ ]
      \ )

call s:add_rules(
      \ #{ filetype: 'vim' },
      \ [
      \   #{ char: '(', at: '\\\%#', input_after: '\)' },
      \   #{ char: '(', at: '\\%\%#', input_after: '\)' },
      \   #{ char: '<Tab>', at: '\%#\\)', leave: '\\)' },
      \   #{ char: '<BS>', at: '\\(\%#\\)', input: '<BS><BS>', delete: '\\)' },
      \   #{ char: '<BS>', at: '\\%(\%#\\)', input: '<BS><BS><BS>', delete: '\\)' },
      \   #{ char: '<CR>', at: '^\s*\\.*\%#$', input: '<CR>\ ' },
      \ ]
      \ )

call s:add_rules(
      \ #{ filetype: ['lisp', 'scheme'] },
      \ [
      \   #{ char: "'", input: "'" },
      \   #{ char: '`', input: '`' },
      \ ]
      \ )

call s:add_rules(
      \ #{ filetype: 'markdown' },
      \ [
      \   #{ char: '<Space>', at: '\[\%#]', input: '<Space>' },
      \   #{ char: '<CR>', at: '^- \[ ] .\+\%#', input: '<CR>- [ ] ' },
      \ ]
      \ )

" input: >>, effect: `if (\%#)condition` -> `if (condition)`
call lexima#add_rule(#{ char: '>', at: '(>\%#)', input: '<BS><DEL><End>)' })

lua << EOF
local snippetTrigger = '<Plug>(expand-bracket)'

local function addLeximaRules()
  local rules = {
    { except = [[\%#(]],    input = '(',  input_after = ')' },
    { input = '',           priority = -1 },
    { filetype = 'haskell', input = '' },
  }
  for _, rule in ipairs(rules) do
    vim.fn['lexima#add_rule'](vim.tbl_deep_extend('error', rule, { char = snippetTrigger }))
  end
end
addLeximaRules()

local function expandBrackets()
  local leximaExpand = require 'rc.utils'.leximaExpand
  local feedkeys = require 'rc.utils'.feedkeys
  feedkeys(leximaExpand('i', snippetTrigger))
end

vim.api.nvim_create_autocmd('CompleteDone', {
  group = 'VimRc',
  callback = function()
    vim.schedule(function()
      if vim.fn.mode() ~= 'i' then
        return
      end
      local item = vim.v.completed_item
      --NOTE: ddc-source-nvim-lspが渡してくるkind文字列に依存している
      if (item.kind == 'Function') or (item.kind == 'Method') then
        expandBrackets()
      end
    end)
  end,
})
EOF

" cmdline rules
" `:g<space>` -> `:vimgrep \%# %`
AlterCmd g vimgrep <Space>%

" ORIGINAL:
"   SOURCE: https://github.com/yuki-yano/lexima-alter-command.vim/blob/main/autoload/lexima_alter_command.vim
"   LICENSE: https://github.com/yuki-yano/lexima-alter-command.vim/blob/main/LICENSE
function! g:AlterCommand(char, input, input_after = v:null) abort
  let space_rule = #{ mode: ':', at: '^\%(''<,''>\)\?' .. a:char, char: '<space>' }
  let cr_rule = #{ mode: ':', at: '^\%(''<,''>\)\?' .. a:char, char: '<cr>' }
  if !a:input->empty()
    let space_rule.input = '<C-w>' .. a:input .. '<space>'
    let cr_rule.input = '<C-w>' .. a:input .. '<cr>'
  endif
  if a:input_after isnot# v:null
    let space_rule.input_after = a:input_after
    let cr_rule.input_after = a:input_after
  endif
  call lexima#add_rule(space_rule)
  call lexima#add_rule(cr_rule)
endfunction

for altercmd in g:_alterCommands
  call g:AlterCommand(altercmd.char, altercmd.input, altercmd.input_after)
endfor
unlet g:_alterCommands

doa User LeximaSetupDone

" }}}
