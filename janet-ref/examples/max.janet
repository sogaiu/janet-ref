(comment

  (max -1 -2 -3)
  # =>
  -1

  (max -2 0 3)
  # =>
  3

  (max)
  # =>
  nil

  (max nil 1)
  # =>
  nil

  (max nil math/inf)
  # =>
  nil

  (max nil math/int32-max math/inf)
  # =>
  nil

  (max math/nan nil)
  # =>
  nil

  (nan? (max math/nan math/inf))
  # =>
  true

  )
