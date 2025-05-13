(comment

  (keep identity [false :x nil true])
  # =>
  @[:x true]

  (keep (fn [x] (when (> x 1) x))
        @[0 1 2 3])
  # =>
  @[2 3]

  (keep (fn [x] (when (> x 2) (* x x)))
        [0 1 3 4 5])
  # =>
  @[9 16 25]

  (keep |(when (pos? (+ ;$&)) $0)
        [1 2 3] [-1 1 1])
  # =>
  @[2 3]

  (keep |(when (neg? (+ ;$&)) $0)
        [-1 -2 -3] [-1 1])
  # =>
  @[-1]

  (keep (fn [elt]
          (when (number? elt)
            elt))
        [1 :a "hello" [0 1 2] 0])
  # =>
  @[1 0]

  (keep (fn [elt]
          (when (number? elt)
            (string elt)))
        [1 :a "hello" [0 1 2] 0])
  # =>
  @["1" "0"]

  (keep (fn [elt]
            (when (even? elt)
              (symbol (string "fun-" elt))))
          [2r111 0x08 8r11 10])
  # =>
  '@[fun-8 fun-10]

  (keep (fn [x]
            (when (>= x (math/pow x 2))
              (math/sqrt x)))
          [0 0.5 1 2 6 8 math/inf])
  # =>
  @[0 (math/sqrt 0.5) 1 math/inf]

  (keep nil [])
  # =>
  @[]

  (keep (fn [x]
          (when (pos? x)
            (string x)))
        (coro
          (for i -3 3
            (yield i))))
  # =>
  @["1" "2"]

  (->> [0 1 2 3 7 8 9]
       (map |(math/pow $ 2))
       (keep (fn [x]
               (when (odd? x)
                 (math/sqrt x)))))
  # =>
  @[1 3 7 9]

  )


