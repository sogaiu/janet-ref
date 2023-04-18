(comment

  (take-while even? [2 6 8 -1])
  # =>
  [2 6 8]

  (take-while odd? @[1 3 7 9 12])
  # =>
  [1 3 7 9]

  (take-while odd? "!zzzzz")
  # =>
  "!"

  (take-while even? @"hhhhha")
  # =>
  "hhhhh"

  (take-while odd? 'my-symbol)
  # =>
  "my-sym"

  (take-while odd? 'my-keyword)
  # =>
  "my-keywo"

  (take-while number? (coro
                        (each elt [1 2 3 :boo!]
                          (yield elt))))
  # =>
  @[1 2 3]

  (take-while nil [])
  # =>
  []


  )
