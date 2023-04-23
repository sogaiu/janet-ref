(comment

  (do
    (var i 3)
    (-= i 2)
    i)
  # =>
  1

  (do
    (var i 1)
    (-= i -1)
    i)
  # =>
  2

  (do
    (var j 0)
    (-= j math/nan)
    (nan? j))
  # =>
  true

  (do
    (var k 0)
    (-= k math/inf)
    k)
  # =>
  math/-inf

  )
