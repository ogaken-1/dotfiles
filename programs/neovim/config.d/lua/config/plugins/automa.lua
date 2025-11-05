return {
  'hrsh7th/nvim-automa',
  event = 'VeryLazy',
  config = function()
    local automa = require 'automa'
    local move_line_or_word_head_and_edit = automa.query_v1 { 'n(b,B,^,0)', 'n', 'no*', 'i*' }
    local move_line_head_and_insert_by_I = automa.query_v1 { 'n(I)', 'i*' }
    --- 「ちょっと前に戻ってなんか編集」という動きをした後に.を押すと次の行で繰り返し実行する
    local function edit_on_word_or_line_head_and_go_next_line(events)
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
      return join_pre_j(move_line_head_and_insert_by_I) or join_pre_j(move_line_or_word_head_and_edit)
    end
    --- cgnは便利だが「検索してちょっと移動して編集」という動作はリピートできない。そういうのもリピート対象にする
    local gn_like = (function()
      local query = automa.query_v1 { 'n(*,#,n,N)', 'n(h,j,k,l,b,B,w,W,e,E)*', 'n', 'no*', 'i*' }
      return function(events)
        -- */#で起動した場合はまた検索しても仕方がないのでn/Nに置換する
        local result = query(events)
        if not result then
          return
        end
        if result.typed:sub(1, 1) == '*' then
          result.typed = 'n' .. result.typed:sub(2)
        elseif result.typed:sub(1, 1) == '#' then
          result.typed = 'N' .. result.typed:sub(2)
        end
        return result
      end
    end)()
    automa.setup {
      mapping = {
        ['.'] = {
          queries = {
            gn_like,
            edit_on_word_or_line_head_and_go_next_line,
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
