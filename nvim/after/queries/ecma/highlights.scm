; extends

(["let" "const"] @skp.var_decl_keyword (#set! priority 100))

; React hooks
(call_expression
  function: (identifier) @skp.hook
  (#lua-match? @skp.hook "^use")
  (#has-ancestor? arrow_function function_declaration))

(this) @skp.this

