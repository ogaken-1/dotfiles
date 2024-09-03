return {
  'ogaken-1/wilder.nvim',
  event = 'CmdlineEnter',
  config = function()
    local wilder = require 'wilder'
    wilder.set_option(
      'pipeline',
      wilder.branch(
        wilder.python_file_finder_pipeline {
          file_command = function(_, arg)
            if vim.fn.stridx(arg, '.') ~= -1 then
              return { 'fd', '-tf', '-H', '--strip-cwd-prefix' }
            else
              return { 'fd', '-tf', '--strip-cwd-prefix' }
            end
          end,
          dir_command = { 'fd', '-td' },
        },
        wilder.cmdline_pipeline { fuzzy = 2, fuzzy_filter = wilder.vim_fuzzy_filter() },
        wilder.search_pipeline(),
        wilder.check(function(_, x)
          return vim.fn.empty(x)
        end),
        wilder.history()
      )
    )
    local cmdline_renderer = wilder.popupmenu_renderer(wilder.popupmenu_border_theme {
      winblend = 20,
      highlighter = wilder.basic_highlighter(),
      highlights = {
        accent = wilder.make_hl(
          'WilderAccent',
          'Pmenu',
          { vim.empty_dict(), vim.empty_dict(), { foreground = '#e27878', bold = true, underline = true } }
        ),
        selected_accent = wilder.make_hl(
          'WIlderSelectedAccent',
          'PmenuSel',
          { vim.empty_dict(), vim.empty_dict(), { foreground = '#e27878', bold = true, underline = true } }
        ),
      },
      left = {
        wilder.popupmenu_devicons { min_width = 2 },
        wilder.popupmenu_buffer_flags { flags = ' ' },
      },
    })
    local search_renderer = wilder.wildmenu_renderer {
      highlighter = wilder.basic_highlighter(),
      separator = ' ',
      left = { ' ' },
      right = { ' ', wilder.wildmenu_index() },
    }
    wilder.setup {
      modes = { ':', '/', '?' },
      accept_key = '<C-e>',
    }
    wilder.set_option(
      'renderer',
      wilder.renderer_mux {
        [':'] = cmdline_renderer,
        ['/'] = search_renderer,
        ['?'] = search_renderer,
      }
    )
  end,
}
