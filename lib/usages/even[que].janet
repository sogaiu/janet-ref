(comment

  (even? 0)
  # =>
  true

  (even? 1)
  # =>
  false

  (even? 2.0)
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
    (even? {:compare a-cmp :mod a-mod :value 2}))
  # =>
  true

  )
