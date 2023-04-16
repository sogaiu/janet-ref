(comment

  (when-let [x 1]
    true)
  # =>
  true

  (when-let [a (even? 3)]
    a)
  # =>
  nil

  (when-let [a (odd? 3)]
    a)
  # =>
  true

  (when-let [a (odd? 3)
             b (even? 3)]
    b)
  # =>
  nil

  (when-let [a (+ 1 6)
             b (- 2 1)]
    (+ a b))
  # =>
  8

  )
