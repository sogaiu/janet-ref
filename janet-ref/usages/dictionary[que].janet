(comment

  (dictionary? {:animal "penguin"
                :drink "green tea"})
  # =>
  true

  (dictionary? @{:x 640 :y 480})
  # =>
  true

  (dictionary? (from-pairs [:color "yellow"
                            :shape "star"]))
  # =>
  true

  (dictionary? (freeze @{:x 1080 :y 720}))
  # =>
  true

  (dictionary? (struct/to-table {:a 1 :b 2}))
  # =>
  true

  (dictionary? (table/to-struct @{:a 1 :b 2}))
  # =>
  true

  (dictionary?
    (tabseq [i :range-to [0 3]]
      i (math/pow i 3)))
  # =>
  true

  (dictionary? nil)
  # =>
  false

  (dictionary? @[])
  # =>
  false

  (dictionary? [])
  # =>
  false

  )
