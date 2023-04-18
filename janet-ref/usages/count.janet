(comment

  (count number? [1 :a "hello" [0 1 2] 0])
  # =>
  2

  (count even? [2r111 0x08 8r11 10])
  # =>
  2

  (count (fn [x]
            (>= x (math/pow x 2)))
         [0 0.5 1 2 6 8 math/inf])
  # =>
  4

  (count nil [])
  # =>
  0

  (count pos?
          (coro
            (for i -3 3
              (yield i))))
  # =>
  2

  (->> [0 1 2 3 7 8 9]
       (map |(math/pow $ 2))
       (count odd?))
  # =>
  4

  )


