(comment

  (find-index number? [1 2 3])
  # =>
  0

  (find-index string? [0 1 "2r111"])
  # =>
  2

  (find-index keyword?
              [0 "fun" [:x :y] {:a 1}]
              :nothing-here)
  # =>
  :nothing-here

  (find-index (fn gachou [x]
                (= x :goose))
              [:duck :duck :duck :goose])
  # =>
  3

  )


