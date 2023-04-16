(comment

  (do
    (defn a-fn
      [&opt arg]
      (default arg 2)
      (+ arg 1))

    (a-fn))
  # =>
  3

  (do
    (defn a-fn
      [&opt arg]
      (default arg 2)
      (+ arg 1))

    (a-fn 7))
  # =>
  8

  (do
    (defn a-fn
      [arg]
      (default arg 2)
      (+ arg 1))

    (a-fn nil))
  # =>
  3

  (do
    (defn a-fn
      [arg]
      (default arg 2)
      (+ arg 1))

    (a-fn 8))
  # =>
  9

  )
