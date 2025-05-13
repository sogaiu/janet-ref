(comment

  (some pos? [math/-inf 0])
  # =>
  nil

  (some (fn [x] (when (pos? x) x)) [1 0 -1])
  # =>
  1

  (some pos? [])
  # =>
  nil

  (some (fn [x y] (neg? (* x y))) [1 1] [1 -2])
  # =>
  true

  (some |(zero? (* $0 $1 $2)) [1 2] [7 8] [-2 -1 0])
  # =>
  nil

  (some |(pos? (+ $0 $1 $2)) [1 2 3] [7 8 9] [])
  # =>
  nil

  )

