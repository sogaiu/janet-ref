(comment

  (accumulate2 + [1 2 3 4])
  # =>
  @[1 3 6 10]

  (accumulate2 + [])
  # =>
  @[]

  (accumulate2 max [1 4 2 3 9 5])
  # =>
  @[1 4 4 4 9 9]

  )

