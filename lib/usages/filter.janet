(comment

  (filter pos? [1 2 3 0 -4 5 6])
  # =>
  @[1 2 3 5 6]

  (filter |(> (length $) 3)
          ["hello" "goodbye" "hi"])
  # =>
  @["hello" "goodbye"]

  (filter |(< (chr "A") $) "foo01bar")
  # =>
  @[102 111 111 98 97 114]

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

  (string/from-bytes ;(filter |(< (chr "A") $) "foo01bar"))
  # =>
  "foobar"

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

