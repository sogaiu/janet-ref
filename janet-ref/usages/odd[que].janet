(comment

  (odd? 0)
  # =>
  false

  (odd? 1)
  # =>
  true

  (odd? 3.0)
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
    (defn a-mod
      [x y]
      (let [x-val (or (get x :value) x)
            y-val (or (get y :value) y)]
        (mod x-val y-val)))
    (odd? {:compare a-cmp :mod a-mod :value -3}))
  # =>
  true

  )
