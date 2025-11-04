return {
  'hrsh7th/nvim-automa',
  event = 'VeryLazy',
  config = function()
    local automa = require 'automa'
    local move_line_or_word_head_and_insert = automa.query_v1 { 'n(b,B,^,0)', 'n(i)', 'i*' }
    local move_line_head_and_insert_by_I = automa.query_v1 { 'n(I)', 'i*' }
    local function word_or_line_head_insert_and_go_next_line(events)
      local function join_pre_j(query)
        local result = query(events)
        if result then
          return {
            s_idx = result.s_idx,
            e_idx = result.e_idx,
            typed = 'j' .. result.typed,
          }
        end
      end
      return join_pre_j(move_line_or_word_head_and_insert) or join_pre_j(move_line_head_and_insert_by_I)
    end
    automa.setup {
      mapping = {
        ['.'] = {
          queries = {
            word_or_line_head_insert_and_go_next_line,
            automa.query_v1 { 'n(:)', 'c+' },
            automa.query_v1 { 'n(V)', '!V(:)*', 'V(:)', '!c(<CR>)+', 'c(<CR>)#' }, -- visualでrange指定するExコマンド
            automa.query_v1 { 'n(V)', 'V*' }, -- visualのあとrange取るコマンド
            automa.query_v1 { 'n+', 'no+', 'n(f,t)', '!c(<CR>)+', 'c(<CR>)#' }, -- sandwich(function, tag)
            automa.query_v1 { 'n', 'no+', 'n#' }, -- sandwich(add,replace,delete)
            automa.query_v1 { 'n', 'no+', 'i*' }, -- cgnとか
            automa.query_v1 { 'n', 'no#' }, -- gc<C-j>とか
            automa.query_v1 { 'n', 'i*' }, -- 殆どのinsert mode入力
            automa.query_v1 { 'n#' }, -- textobjectを使用しない編集コマンド
          },
        },
      },
    }
  end,
}
