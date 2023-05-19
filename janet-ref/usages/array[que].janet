(comment

  (array? @[:a :b])
  # =>
  true

  (array? @(:x :y :z))
  # =>
  true

  (array? (map inc [-2 -1 0]))
  # =>
  true

  (array? (filter odd? [-1 0 1]))
  # =>
  true

  (array? (peg/match '(sequence (thru ".")) "hello there."))
  # =>
  true

  (array? (peg/match '(sequence (thru ".")) "hello there?"))
  # =>
  false

  (array? [])
  # =>
  false

  (array? '())
  # =>
  false

  )
