function! config#plugin#wilder() abort
  function! s:fzf_filter(ctx, candidates, query) abort
    return ['fzf', '-f', a:query]
        \ ->systemlist(a:candidates->map({ _, word -> word->printf("'%s'") }))
        \ ->map({ _, word -> word->substitute("^'\\(.\\+\\)'$", '\1', '') })
  endfunction

  call wilder#set_option('pipeline', [
        \ wilder#branch(
        \   wilder#python_file_finder_pipeline(#{
        \     file_command: {_, arg -> stridx(arg, '.') != -1 ? ['fd', '-tf', '-H', '--strip-cwd-prefix'] : ['fd', '-tf', '--strip-cwd-prefix']},
        \     dir_command: ['fd', '-td'],
        \   }),
        \   wilder#cmdline_pipeline(#{
        \     fuzzy: 2,
        \     fuzzy_filter: function('s:fzf_filter'),
        \   }),
        \   [
        \     wilder#check({_, x -> empty(x)}),
        \     wilder#history(),
        \   ],
        \   wilder#python_search_pipeline(#{
        \     pattern: wilder#python_fuzzy_pattern(#{
        \       start_at_boundary: 0,
        \     }),
        \   }),
        \ ),
        \ ])

  let wilder_cmd_line_renderer = wilder#popupmenu_renderer(wilder#popupmenu_border_theme(#{
        \ winblend: 20,
        \ highlighter: wilder#basic_highlighter(),
        \ highlights: #{
        \   accent: wilder#make_hl('WilderAccent', 'Pmenu', [{}, {}, #{foreground: '#e27878', bold: v:true, underline: v:true}]),
        \   selected_accent: wilder#make_hl('WilderSelectedAccent', 'PmenuSel', [{}, {}, #{foreground: '#e27878', bold: v:true, underline: v:true}]),
        \ },
        \ left: [wilder#popupmenu_devicons(#{min_width: 2}), wilder#popupmenu_buffer_flags(#{flags: ' '})],
        \ }))

  let wilder_search_renderer = wilder#wildmenu_renderer(#{
        \ highlighter: wilder#basic_highlighter(),
        \ separator: '  ',
        \ left: [' '],
        \ right: [' ', wilder#wildmenu_index()],
        \ })

  call wilder#setup(#{
        \ modes: [':', '/', '?'],
        \ enable_mappings: v:false,
        \ })

  call wilder#set_option(
        \ 'renderer',
        \ wilder#renderer_mux({
        \   ':': wilder_cmd_line_renderer,
        \   '/': wilder_search_renderer,
        \   '?': wilder_search_renderer,
        \ })
        \ )

  call dein#source(
        \ dein#get()
        \ ->filter({ _, p -> !p->get('is_sourced', 0) && p->has_key('on_cmd') })
        \ ->values()
        \ ->map({ _, p -> p.name })
        \ )
endfunction
