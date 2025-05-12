(comment

  (string/trimr "  foo ")
  # =>
  "  foo"

  (string/trimr "\t bar\n\r\f")
  # =>
  "\t bar"

  (string/trimr "_.foo_bar. \n" " ._\n")
  # =>
  "_.foo_bar"

  )

