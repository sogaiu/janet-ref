(comment

  (find number? [1 2 3])
  # =>
  1

  (find string? [0 1 "2r111"])
  # =>
  "2r111"

  (find keyword?
        [0 "fun" [:x :y] {:a 1}]
        :nothing-here)
  # =>
  :nothing-here

  (find (fn gachou [x]
          (= x :goose))
        [:duck :duck :duck :goose])
  # =>
  :goose

  )


