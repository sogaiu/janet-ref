(comment

  (pos? 0)
  # =>
  false

  (pos? -1)
  # =>
  false

  (pos? 1)
  # =>
  true

  (pos? math/inf)
  # =>
  true

  (pos? math/-inf)
  # =>
  false

  (pos? math/nan)
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
  (pos? {:compare a-cmp :value 1}))
  # =>
  true

  )
