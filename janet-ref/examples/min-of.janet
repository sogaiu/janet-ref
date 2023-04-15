(comment

  (min-of [-1 -2 -3])
  # =>
  -3

  (min-of [-2 0 3])
  # =>
  -2

  (min-of [])
  # =>
  nil

  (min-of [nil 1])
  # =>
  1

  (min-of [nil math/inf])
  # =>
  math/inf

  (min-of [nil math/int32-max math/inf])
  # =>
  math/int32-max

  (nan? (min-of [math/nan nil]))
  # =>
  true

  (nan? (min-of [math/nan math/inf]))
  # =>
  true

  )
