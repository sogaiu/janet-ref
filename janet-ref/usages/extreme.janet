(comment

  (extreme < [1 0 -1])
  # =>
  -1

  (extreme > [-1 0 1])
  # =>
  1

  (extreme (fn [x y]
             (> (math/pow x 3) (math/pow y 3)))
           [-1 -0.5 0 0.3 0.6])
  # =>
  0.6

  (extreme < [])
  # =>
  nil

  (extreme > [math/int32-max math/inf])
  # =>
  math/inf

  (extreme > [math/int32-max math/inf nil])
  # =>
  nil

  )
