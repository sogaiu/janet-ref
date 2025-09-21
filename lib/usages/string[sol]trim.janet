(comment

  (string/trim "  foo ")
  # =>
  "foo"

  (string/trim "\t bar\n\r\f")
  # =>
  "bar"

  (string/trim "_.foo_bar. \n" " ._\n")
  # =>
  "foo_bar"

  )

