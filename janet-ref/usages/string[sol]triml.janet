(comment

  (string/triml "  foo ")
  # =>
  "foo "

  (string/triml "\t bar\n\r\f")
  # =>
  "bar\n\r\f"

  (string/triml "_.foo_bar. \n" " ._\n")
  # =>
  "foo_bar. \n"

  )

