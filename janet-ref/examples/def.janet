(comment

  (do
    (def a 1)
    a)
  # =>
  1

  (do
    (def a 1)
    (def a 2)
    a)
  # =>
  2

  (do
    (def a 1)
    (do
      (def a 2))
    a)
  # =>
  1

  (do
    (def [a b]
      [1 2])
    a)
  # =>
  1

  (do
    (def [x y & rest]
      [1 2 3 8 9])
    rest)
  # =>
  '(3 8 9)

  (do
    (def {:a a
          :b b}
      (table :a 1
             :b 2))
    b)
  # =>
  2

  )
