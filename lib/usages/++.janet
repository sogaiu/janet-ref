(comment

  (do
    (var i 0)
    (++ i)
    i)
  # =>
  1

  (do
    (var i -1)
    (++ i))
  # =>
  0

  (do
    (var i math/inf)
    (++ i))
  # =>
  math/inf

  (do
    (var i math/-inf)
    (++ i))
  # =>
  math/-inf

  (do
    (var i math/nan)
    (++ i)
    (nan? i))
  # =>
  true

  )
