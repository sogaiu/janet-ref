(comment

  (do
    (def arr @[])
    (var i 0)
    (repeat 3
      (array/push arr i)
      (++ i))
    arr)
  # =>
  @[0 1 2]

  )
