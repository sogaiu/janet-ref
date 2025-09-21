(comment

  (do
    (def g inc)
    (def f |(math/pow $ 2))
    (def h (comp g f))
    (h 3))
  # =>
  10

  ((comp inc |(math/pow $ 2))
    3)
  # =>
  10

  (do
    (def g inc)
    (def f dec)
    (def h (comp g f))
    (h 42))
  # =>
  42

  ((comp inc dec)
    42)
  # =>
  42

  ((comp (fn g [xs]
           (map inc xs))
         (fn f [xs]
           (map |(math/pow $ 3) xs)))
    [0 1 2])
  # =>
  @[1 2 9]

  )
