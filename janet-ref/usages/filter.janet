(comment

  (filter number? [1 :a "hello" [0 1 2] 0])
  # =>
  @[1 0]

  (filter even? [2r111 0x08 8r11 10])
  # =>
  @[8 10]

  (filter (fn [x]
            (>= x (math/pow x 2)))
          [0 0.5 1 2 6 8 math/inf])
  # =>
  @[0 0.5 1 math/inf]

  (filter nil [])
  # =>
  @[]

  (filter pos?
          (coro
            (for i -3 3
              (yield i))))
  # =>
  @[1 2]

  (->> [0 1 2 3 7 8 9]
       (map |(math/pow $ 2))
       (filter odd?)
       (map math/sqrt))
  # =>
  @[1 3 7 9]

  )


