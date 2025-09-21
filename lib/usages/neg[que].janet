(comment

  (neg? 0)
  # =>
  false

  (neg? -1)
  # =>
  true

  (neg? 1)
  # =>
  false

  (neg? math/inf)
  # =>
  false

  (neg? math/-inf)
  # =>
  true

  (neg? math/nan)
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
  (neg? {:compare a-cmp :value -1}))
  # =>
  true

  )
