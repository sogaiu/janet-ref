(comment

  (do
    (defn a-cmp
      [x y]
      (let [x-val (get x :value)
            y-val (get y :value)]
        (cond
          (< x-val y-val) -1
          (= x-val y-val) 0
          (> x-val y-val) 1)))
    (compare {:compare a-cmp :value 1}
             {:compare a-cmp :value 2}))
  # =>
  -1

  (do
    (defn a-cmp
      [x y]
      (let [x-val (get x :value)
            y-val (get y :value)]
        (cond
          (< x-val y-val) -1
          (= x-val y-val) 0
          (> x-val y-val) 1)))
    (compare {:compare a-cmp :value 1}
             {:compare a-cmp :value 1}))
  # =>
  0

  (do
    (defn a-cmp
      [x y]
      (let [x-val (get x :value)
            y-val (get y :value)]
        (cond
          (< x-val y-val) -1
          (= x-val y-val) 0
          (> x-val y-val) 1)))
    (compare {:compare a-cmp :value 1}
             {:value 2}))
  # =>
  -1

  (do
    (defn a-cmp
      [x y]
      (let [x-val (get x :value)
            y-val (get y :value)]
        (cond
          (< x-val y-val) -1
          (= x-val y-val) 0
          (> x-val y-val) 1)))
    (compare {:value 1}
             {:compare a-cmp :value 2}))
  # =>
  -1

  (do
    (defn a-cmp
      [x y]
      (let [x-val (or (get x :value) x)
            y-val (or (get y :value) y)]
        (cond
          (< x-val y-val) -1
          (= x-val y-val) 0
          (> x-val y-val) 1)))
    (compare 1
             {:compare a-cmp :value 2}))
  # =>
  -1

  (compare -1 1)
  # =>
  -1

  )
