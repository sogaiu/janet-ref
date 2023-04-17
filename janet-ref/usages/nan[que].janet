(comment

  (nan? math/nan)
  # =>
  true

  (nan? (/ 0 0))
  # =>
  true

  (nan? (inc math/nan))
  # =>
  true

  (nan? (dec math/nan))
  # =>
  true

  (nan? (/ math/nan math/nan))
  # =>
  true

  (nan? (* 0 math/nan))
  # =>
  true

  (nan? nil)
  # =>
  false

  )
