(comment

  (+ 1 2)
  # =>
  3

  (+ 10)
  # =>
  10

  (+)
  # =>
  0

  (+ 1.4 -4.5)
  # =>
  -3.1

  (+ 1 2 3 4 5 6 7 8 9 10)
  # =>
  55

  (+ ;(range 101))
  # =>
  5050

  (= (+ (int/s64 "10") 10)
     20:s)
  # =>
  true

  (def [ok? value] (protect (+ nil 10)))
  # =>
  [false "could not find method :+ for nil"]

  )

