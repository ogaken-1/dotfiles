(section
  (heading
    (text) @name)
  (#set! "kind" "Struct")) @symbol

(let
  pattern: (call
             item: (ident) @name)
  (#set! "kind" "Function")) @symbol
