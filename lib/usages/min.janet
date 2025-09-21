(comment

  (min -1 -2 -3)
  # =>
  -3

  (min -2 0 3)
  # =>
  -2

  (min)
  # =>
  nil

  (min nil 1)
  # =>
  1

  (min nil math/inf)
  # =>
  math/inf

  (min nil math/int32-max math/inf)
  # =>
  math/int32-max

  (nan? (min math/nan nil))
  # =>
  true

  (nan? (min math/nan math/inf))
  # =>
  true

  )
