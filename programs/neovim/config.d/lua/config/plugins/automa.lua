return {
  'hrsh7th/nvim-automa',
  event = 'VeryLazy',
  config = function()
    local automa = require 'automa'
    automa.setup {
      mapping = {
        ['.'] = {
          queries = {
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
