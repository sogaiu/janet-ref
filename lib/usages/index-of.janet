(comment

  (index-of 2 [1 2 3])
  # =>
  1

  (index-of 7 [0 1 2r111])
  # =>
  2

  (index-of :arthur
            [0 "fun" [:x :y] {:a 1}]
            :nothing-here)
  # =>
  :nothing-here

  )


