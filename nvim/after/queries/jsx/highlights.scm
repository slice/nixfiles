; extends

(jsx_opening_element name: (identifier) @skp.tag.opening)
(jsx_opening_element (member_expression (identifier) @tag.builtin (property_identifier)) @skp.tag.opening)
(jsx_closing_element name: (identifier) @skp.tag.closing)
(jsx_closing_element (member_expression (identifier) @tag.builtin (property_identifier)) @skp.tag.closing)
