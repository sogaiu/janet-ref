(comment

  (table? @{:x 640 :y 480})
  # =>
  true

  (table? {:animal "penguin"
           :drink "green tea"})
  # =>
  false

  (table? (from-pairs [:color "yellow"
                       :shape "star"]))
  # =>
  true

  (table? (struct/to-table {:a 1 :b 2}))
  # =>
  true

  (table? (tabseq [i :range-to [0 3]]
            i (math/pow i 3)))
  # =>
  true

  )
