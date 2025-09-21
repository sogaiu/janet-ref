(comment

  (string? "hello")
  # =>
  true

  (string?
    ``
    even long-strings
    are strings
    ``)
  # =>
  true

  (string? @"")
  # =>
  false

  (string? (string @"hi"))
  # =>
  true

  )
