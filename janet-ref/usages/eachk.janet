(comment

  (do
    (def arr @[])
    (def a-struct {:a 1 :b 2})
    (eachk k a-struct
      (array/push arr (get a-struct k)))
    (sort arr))
  # =>
  @[1 2]

  (let [arr @[]
        tbl @{:x 1 :y 2 :z 3}]
    (eachk k tbl
      (when (= k :z) (break))
      (array/push arr k))
    (not= (length arr) (length tbl)))
  # =>
  true

  )
