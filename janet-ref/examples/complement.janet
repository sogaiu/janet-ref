(comment

  (do
    (def f (complement pos?))
    (f 1))
  # =>
  false

  (do
    (def f (complement zero?))
    (f 1))
  # =>
  true

  ((complement even?) 1)
  # =>
  true

  )
