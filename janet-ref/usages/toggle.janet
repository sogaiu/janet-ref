(comment

  (do
    (var a true)
    (toggle a))
  # =>
  false

  (do
    (var b false)
    (toggle b))
  # =>
  true

  (do
    (var c nil)
    (toggle c))
  # =>
  true

  (do
    (var x 1)
    (toggle x))
  # =>
  false

  )
