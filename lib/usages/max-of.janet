(comment

  (max-of [-1 -2 -3])
  # =>
  -1

  (max-of [-2 0 3])
  # =>
  3

  (max-of [])
  # =>
  nil

  (max-of [nil 1])
  # =>
  nil

  (max-of [nil math/inf])
  # =>
  nil

  (max-of [nil math/int32-max math/inf])
  # =>
  nil

  (max-of [math/nan nil])
  # =>
  nil

  (nan? (max-of [math/nan math/inf]))
  # =>
  true

  )
