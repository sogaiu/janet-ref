(comment

  (struct? {:animal "penguin"
            :drink "green tea"})
  # =>
  true

  (struct? @{:x 640 :y 480})
  # =>
  false

  (struct? (freeze @{:x 1080 :y 720}))
  # =>
  true

  (struct? (table/to-struct @{:a 1 :b 2}))
  # =>
  true

  )
