(comment

  (do
    (var a 1)
    a)
  # =>
  1

  (do
    (var a 1)
    (var a 2)
    a)
  # =>
  2

  (do
    (var a 1)
    (set a 3)
    a)
  # =>
  3

  (do
    (var a 1)
    (do
      (var a 2))
    a)
  # =>
  1

  (do
    (var [a b]
      [1 2])
    a)
  # =>
  1

  (do
    (var [x y & rest]
      [1 2 3 8 9])
    rest)
  # =>
  '(3 8 9)

  (do
    (var {:a a
          :b b}
      (table :a 1
             :b 2))
    b)
  # =>
  2

  )
