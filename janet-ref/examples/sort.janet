(comment

  (do
    (def arr @[2 0 1])
    (sort arr)
    arr)
  # =>
  @[0 1 2]

  (do
    (def arr @[2 0 1])
    (sort arr >)
    arr)
  # =>
  @[2 1 0]

  (do
    (def arr @[[:fun 0] [:swim 2] [:play -1]])
    (sort arr (fn [[_ x] [_ y]]
                (< x y)))
    arr)
  # =>
  '@[(:play -1) (:fun 0) (:swim 2)]

  )
