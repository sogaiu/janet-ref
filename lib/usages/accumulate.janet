(comment

  (accumulate + 0 [1 2 3])
  # =>
  @[1 3 6]

  (accumulate (fn [x y]
                (if (not (empty? x))
                  (string x ", " y)
                  y))
              ""
              [:ant :bee :cheetah])
  # =>
  @[:ant "ant, bee" "ant, bee, cheetah"]

  (accumulate nil nil [])
  # =>
  @[]

  (accumulate nil :garuda [])
  # =>
  @[]

  )
