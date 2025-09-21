(comment

  (do
    (def arr @[2 0 1])
    [(sorted arr) arr])
  # =>
  [@[0 1 2] @[2 0 1]]

  (do
    (def arr @[2 0 1])
    [(sorted arr >) arr])
  # =>
  [@[2 1 0] @[2 0 1]]

  (do
    (def arr @[[:fun 0] [:swim 2] [:play -1]])
    [(sorted arr (fn [[_ x] [_ y]]
                  (< x y)))
     arr])
  # =>
  '(@[(:play -1) (:fun 0) (:swim 2)]
     @[(:fun 0) (:swim 2) (:play -1)])

  )
