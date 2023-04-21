(comment

  (zero? 0)
  # =>
  true

  (zero? -0)
  # =>
  true

  (zero? 0.0)
  # =>
  true

  (zero? math/nan)
  # =>
  false

  (zero? math/inf)
  # =>
  false

  )
