(comment

  (and)
  # =>
  true

  (and 1)
  # =>
  1

  (and 1 nil)
  # =>
  nil

  (and 1 (/ 2 1) false)
  # =>
  false

  (and :fun :play (not true) :dance)
  # =>
  false

  )
