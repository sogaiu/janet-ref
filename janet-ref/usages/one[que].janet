(comment

  (one? 0)
  # =>
  false

  (one? 1)
  # =>
  true

  (one? 1.0)
  # =>
  true

  (do
    (defn a-cmp
      [x y]
      (let [x-val (or (get x :value) x)
            y-val (or (get y :value) y)]
        (cond
          (< x-val y-val) -1
          (= x-val y-val) 0
          (> x-val y-val) 1)))
    (one? {:compare a-cmp :value 1}))
  # =>
  true

  )
