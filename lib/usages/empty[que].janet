(comment

  (empty? [])
  # =>
  true

  (empty? @{})
  # =>
  true

  (empty? "")
  # =>
  true

  (empty? [1])
  # =>
  false

  (empty? @[])
  # =>
  true

  (def [ok? value] (protect (empty? 0)))
  # =>
  [false "expected iterable type, got 0"]

  )

