(comment

  (identity 3)
  # =>
  3

  (nan? (identity math/nan))
  # =>
  true

  (identity math/inf)
  # =>
  math/inf

  (= identity
     (identity identity))
  # =>
  true

  )
