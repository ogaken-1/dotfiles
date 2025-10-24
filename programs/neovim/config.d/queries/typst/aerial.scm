(section
  (heading
    (text) @name)
  (#set! "kind" "Interface")) @symbol

(let
  pattern: (call
             item: (ident) @name)
  (#set! "kind" "Function")) @symbol
