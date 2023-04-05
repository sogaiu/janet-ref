(comment

  (do
    (def coll @[])
    (forv i 0 9
      (array/push coll i)
      (+= i 2))
    coll)
  # =>
  @[0 3 6]

  (do
    (def coll @[])
    (forv i 0 9
      (array/push coll i)
      (*= i -2))
    coll)
  # =>
  @[0 1 -1 3 -5]


  )
