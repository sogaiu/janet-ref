(comment

  (if-let [x 1]
    true
    false)
  # =>
  true

  (if-let [x 1]
    true)
  # =>
  true

  (if-let [a (even? 3)]
    a
    false)
  # =>
  false

  (if-let [a (even? 3)]
    a)
  # =>
  nil

  (if-let [a (odd? 3)]
    a
    false)
  # =>
  true

  (if-let [a (odd? 3)]
    a)
  # =>
  true

  (if-let [a (odd? 3)
           b (even? 3)]
    b
    false)
  # =>
  false

  (if-let [a (odd? 3)
           b (even? 3)]
    b)
  # =>
  nil

  (if-let [a (+ 1 6)
           b (- 2 1)]
    (+ a b)
    false)
  # =>
  8

  (if-let [a (+ 1 6)
           b (- 2 1)]
    (+ a b))
  # =>
  8

  )
