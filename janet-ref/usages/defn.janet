(comment

  (do
    (defn my-fn
      [x]
      (+ x 1))

    (my-fn 2))
  # =>
  3

  (do
    (defn my-documented-fn
      "What a nice doc-string..."
      [x]
      (+ x 11))

    (my-documented-fn 0))
  # =>
  11

  (do
    (defn outer-fn
      [x]
      (defn inner-fn
        [y]
        (+ x y))

      (inner-fn 1))

    (outer-fn 2))
  # =>
  3

  )
