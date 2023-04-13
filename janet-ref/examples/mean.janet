(comment

  (mean [1 2 3 4 5])
  # =>
  3

  (nan? (mean []))
  # =>
  true

  (mean (range 0 1001))
  # =>
  500

  (mean {:a 2 :e 6})
  # =>
  4

  )
