;; extends

[
  "("
  ")"
] @punctuation.bracket.paren

[
  "{"
  "}"
] @punctuation.bracket.brace

[
  "["
  "]"
] @punctuation.bracket.square

[
  ","
] @punctuation.comma

[
  "."
] @punctuation.period


[
  "%="
  "&="
  "&^="
  "*="
  "+="
  "-="
  "/="
  ":="
  "<<="
  "="
  ">>="
] @operator.assign

(interpreted_string_literal
  "\"" @string.delimiter
  (interpreted_string_literal_content) @string
  "\"" @string.delimiter)

(raw_string_literal
  "`" @string.delimiter
  (raw_string_literal_content) @string
  "`" @string.delimiter)
