(comment

  (take 2 [0 1 2 3])
  # =>
  [0 1]

  (take 3 (range -3 0))
  # =>
  [-3 -2 -1]

  (take 2 "hiya")
  # =>
  "hi"

  (take 3 (coro
            (each i (range 10)
              (yield i))))
  # =>
  @[0 1 2]

  (take 0 "hiya")
  # =>
  ""

  (take 0 (range 100))
  # =>
  []

  (take 0 (coro (yield :a)))
  # =>
  @[]

  )
