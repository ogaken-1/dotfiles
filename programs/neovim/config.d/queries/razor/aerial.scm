;; inherits: c_sharp

((element) @name
           (#gsub! @name "^<([A-Za-z0-9]+)[^>]*\/?>.*$" "%1")
           (#set! kind "Struct")) @symbol

;; Attributes of Razor components are not provided as visible tree-sitter nodes.

;; Razor files are procedures for rendering a single component for the entire file.
;; It seems appropriate to display control statements as structure.

((razor_if
   (razor_condition) @name)
 (#gsub! @name "^(.*)$" "@if %1")
 (#set! kind "Operator")) @symbol

((razor_foreach) @name
 (#gsub! @name "^@foreach%s*%(([^()]+)%).*$" "@foreach (%1)")
 (#set! kind "Operator")) @symbol

((razor_for) @name
 (#gsub! @name "^@for%s*%(([^()]+)%).*$" "@for (%1)")
 (#set! kind "Operator")) @symbol

((razor_while) @name
 (#gsub! @name "^@while%s*%(([^()]+)%).*$" "@while (%1)")
 (#set! kind "Operator")) @symbol

((razor_switch
   (razor_condition) @name)
 (#gsub! @name "^(.*)$" "@switch %1")
 (#set! kind "Operator")) @symbol
