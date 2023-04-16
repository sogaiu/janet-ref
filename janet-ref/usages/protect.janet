(comment

  (protect (+ 1 1))
  # =>
  [true 2]

  (protect (error "oops"))
  # =>
  [false "oops"]

  )
