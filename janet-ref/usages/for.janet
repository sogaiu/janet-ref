(comment

  (do
    (def arr @[])
    (for i 0 7
      (array/push arr (math/pow i 2)))
    arr)
  # =>
  @[0 1 4 9 16 25 36]

  (do
    (def arr @[])
    (for i 0 3
      (for j 0 3
        (array/push arr [i j])))
    arr)
  # =>
  '@[(0 0) (0 1) (0 2)
     (1 0) (1 1) (1 2)
     (2 0) (2 1) (2 2)]

  )
