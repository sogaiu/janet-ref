(comment

  (do
    (def arr @[])
    (def struct {:a 1 :b 2})
    (eachk k struct
      (array/push arr (get struct k)))
    arr)
  # =>
  @[1 2]

  (do
    (def arr @[])
    (def tbl @{:x 1
               :y 2
               :z 3})
    (eachk k tbl
      (when (= k :z)
        (break))
      (array/push arr k))
    (not= (length arr) (length tbl)))
  # =>
  true

  )
