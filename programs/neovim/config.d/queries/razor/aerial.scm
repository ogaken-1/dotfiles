((element) @name
           (#gsub! @name "^<([A-Za-z]+[0-9]?).*$" "%1")
           (#set! "kind" "Struct")) @symbol

((method_declaration
   name: (identifier) @name)
 (#set! "kind" "Method")) @symbol
