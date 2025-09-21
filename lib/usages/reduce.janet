(comment

  (reduce + 0 [1 2 3])
  # =>
  6

  (reduce (fn [x y]
            (if (not (empty? x))
              (string x ", " y)
              y))
          ""
          [:ant :bee :cheetah])
  # =>
  "ant, bee, cheetah"

  (reduce nil nil [])
  # =>
  nil

  (reduce nil :garuda [])
  # =>
  :garuda

  )
