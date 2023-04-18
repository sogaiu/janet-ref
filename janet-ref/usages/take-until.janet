(comment

  (take-until even? [-1 1 3 8])
  # =>
  [-1 1 3]

  (take-until odd? @[2 6 8 12 13])
  # =>
  [2 6 8 12]

  (take-until odd? "zzzzz!")
  # =>
  "zzzzz"

  (take-until even? @"ooooooh")
  # =>
  "oooooo"

  (take-until even? 'my-symbol)
  # =>
  "my-sym"

  (take-until even? 'my-keyword)
  # =>
  "my-keywo"

  (take-until number? (coro
                        (each elt [:a "fun" @"thing" 0]
                          (yield elt))))
  # =>
  @[:a "fun" @"thing"]

  (take-until nil [])
  # =>
  []


  )
