(comment

  (cfunction? getline)
  # =>
  true

  (cfunction? inc)
  # =>
  false

  [(cfunction? print) (function? print)]
  # =>
  [true false]

  )
