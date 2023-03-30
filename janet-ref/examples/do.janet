(comment

  (do)
  # =>
  nil

  (do
    true)
  # =>
  true

  (do
    (print "hi")
    (+ 1 1))
  # =>
  2

  (do
    (do
      :fun))
  # =>
  :fun

  (do
    (def a 1)
    a)
  # =>
  1

  (do
    (def a 1)
    (do
      (def a 2))
    a)
  # =>
  1

  )
