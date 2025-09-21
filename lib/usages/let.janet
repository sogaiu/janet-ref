(comment

  (let [x 1]
    x)
  # =>
  1

  (let []
    2)
  # =>
  2

  (let [a (+ 2 3)
        b (inc a)]
    b)
  # =>
  6

  (do
    (var x 1)
    (let [a 1
          _ (set x (inc a))
          b (inc x)]
      b))
  # =>
  3

  )
