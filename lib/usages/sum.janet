(comment

  (sum [])
  # =>
  0

  (sum [1 2])
  # =>
  3

  (sum @[1])
  # =>
  1

  (sum (range 1 100))
  # =>
  4950

  (sum @{:a 2 :e 6})
  # =>
  8

  (sum {:a 1 :b 2 :c 4})
  # =>
  7

  )
