(comment

  (do
    (def arr @[])
    (array/concat arr @[:a])
    arr)
  # =>
  @[:a]

  (do
    (def arr @[])
    (array/concat arr [:a :b])
    arr)
  # =>
  @[:a :b]

  (do
    (def arr @[])
    (array/concat arr :a)
    arr)
  # =>
  @[:a]

  (do
    (def arr @[])
    (array/concat arr :a :b)
    arr)
  # =>
  @[:a :b]

  (do
    (def arr @[])
    (array/concat arr :a @[:x] [:y])
    arr)
  # =>
  @[:a :x :y]

  (do
    (def arr @[])
    (array/concat arr [[:x] :y])
    arr)
  # =>
  @[[:x] :y]

  )
