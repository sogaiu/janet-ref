(comment

  (let [arr @[]]
    (eachp [k v] {:ant 1 :bee 2}
      (array/push arr [k v]))
    (sort arr))
  # =>
  @[[:ant 1] [:bee 2]]

  (let [two-legs @[]
        six-legs @[]
        wings @[]]
    (eachp [k v] {:ant :insect :bee :insect :magpie :bird}
      (cond
        (= v :insect) (array/push six-legs k)
        (= v :bird) (array/push two-legs k))
      (when (or (= k :bee) (= k :magpie))
        (array/push wings k)))
    (map sort [two-legs six-legs wings]))
  # =>
  @[@[:magpie]
    @[:ant :bee]
    @[:bee :magpie]]

  )

