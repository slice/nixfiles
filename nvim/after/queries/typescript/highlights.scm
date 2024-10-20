; extends

[ "break" ] @skp.break

[ "=>" ] @skp.fat_arrow

; sometimes it thinks `React` is a type…?
[(predefined_type) (type_identifier)] @skp.type_like_actually

; constructor definition
(method_definition
  name: (property_identifier) @skp.constructor
  (#eq? @skp.constructor "constructor")
  (#has-ancestor? @skp.constructor class_body))

; major declaration (like, functions)
(_
  name: (identifier) @skp.major_decl
  type: (type_annotation
          (generic_type
            name: (nested_type_identifier
                    module: (identifier) @_name
                    name: (type_identifier)
                    (#eq? @_name "React"))))) ; <name>: React.… = …
(method_definition name: (property_identifier) @skp.major_decl) ; <name>() { … }
(_
  name: (property_identifier) @skp.major_decl
  value: (arrow_function)
  (#has-ancestor? @skp.major_decl class_body)) ; class … { <name> = () => … }
(program
  [(lexical_declaration
    (variable_declarator
      name: (identifier) @skp.major_decl
      value: [(arrow_function) ; top-level const/let <name> = () => …
              (call_expression ; top-level const/let <name> = …(() => …) (wrapped React components)
                arguments: (arguments .
                             (arrow_function)))]))
   (export_statement
    declaration: [(function_declaration ; top-level export function <name>() { … }
                   name: (identifier) @skp.major_decl)
                  (lexical_declaration ; top-level export const/let <name> = () => …
                    (variable_declarator
                      name: (identifier) @skp.major_decl
                      value: (arrow_function)))])
   (function_declaration ; top-level function <name>() { … }
     name: (identifier) @skp.major_decl)])
