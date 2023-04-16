(comment

  (do
    (def two-legs @[])
    (def six-legs @[])
    (def wings @[])
    (def backyard {:ant :insect
                   :bee :insect
                   :magpie :bird})
    (eachp [k v] backyard
      (when (= v :insect)
        (array/push six-legs k))
      (when (= v :bird)
        (array/push two-legs k))
      (when (or (= k :bee)
                (= k :magpie))
        (array/push wings k)))
    (map sort
         [two-legs six-legs wings]))
  # =>
  @[@[:magpie]
    @[:ant :bee]
    @[:bee :magpie]]

  )
