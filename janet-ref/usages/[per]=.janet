(comment

  (do
    (var i 3)
    (%= i 2)
    i)
  # =>
  1

  (do
    (var i 17)
    (%= i -7)
    i)
  # =>
  3

  (do
    (var j 1024)
    (%= j math/nan)
    (nan? j))
  # =>
  true

  (do
    (var k 2048)
    (%= k math/inf)
    k)
  # =>
  2048

  )
