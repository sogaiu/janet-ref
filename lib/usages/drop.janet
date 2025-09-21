(comment

  (drop 2 [:ant :bee :cheetah])
  # =>
  [:cheetah]

  (drop -2 [0 1 2])
  # =>
  [0]

  (drop 2 "spice")
  # =>
  "ice"

  (drop 0 :oops)
  # =>
  "oops"

  (drop -1 :oops)
  # =>
  "oop"

  (drop -1 'print)
  # =>
  "prin"

  (drop 0 @[0 1 2])
  # =>
  [0 1 2]

  (drop 0 [])
  # =>
  []

  (drop 1 [])
  # =>
  []

  )
