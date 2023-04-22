(comment

  (zero? 0)
  # =>
  true

  (zero? -0)
  # =>
  true

  (zero? 0.0)
  # =>
  true

  (zero? math/nan)
  # =>
  false

  (zero? math/inf)
  # =>
  false

  (do
    (defn a-cmp
      [x y]
      (let [x-val (or (get x :value) x)
            y-val (or (get y :value) y)]
        (cond
          (< x-val y-val) -1
          (= x-val y-val) 0
          (> x-val y-val) 1)))
    (zero? {:compare a-cmp :value 0}))
  # =>
  true

  )
