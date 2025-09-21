(comment

  (do
    (var tot 3)
    (seq [i :iterate (when (pos? (-- tot)) tot)]
      i))
  # =>
  @[2 1]

  (seq [i :range [0 4]]
    i)
  # =>
  @[0 1 2 3]

  (seq [i :range [0 4 2]]
    i)
  # =>
  @[0 2]

  (seq [i :range-to [8 12]]
    i)
  # =>
  @[8 9 10 11 12]

  (seq [i :range-to [8 12 2]]
    i)
  # =>
  @[8 10 12]

  (seq [j :down [10 0]]
    j)
  # =>
  @[10 9 8 7 6 5 4 3 2 1]

  (seq [j :down [10 0 2]]
    j)
  # =>
  @[10 8 6 4 2]

  (seq [j :down-to [3 -3]]
    j)
  # =>
  @[3 2 1 0 -1 -2 -3]

  (seq [j :down-to [3 -3 3]]
    j)
  # =>
  @[3 0 -3]

  (sort
    (seq [k :keys {:a 1 :b 2}]
      k))
  # =>
  @[:a :b]

  (sort
    (seq [[k v] :pairs {:a 1 :b 2}]
      [v k]))
  # =>
  @[[1 :a] [2 :b]]

  (seq [i :in [0 1 2]]
    (math/pow i 3))
  # =>
  @[0 1 8]

  (seq [i :in (fiber/new
                |(each x (range 3)
                   (yield x)))]
    (math/pow i 3))
  # =>
  @[0 1 8]

  (seq [i :range [-3 3 0.5]
        :while (not (pos? i))]
    i)
  # =>
  @[-3 -2.5 -2 -1.5 -1 -0.5 0]

  (seq [i :range [-3 3 0.5]
        :until (pos? i)]
    i)
  # =>
  @[-3 -2.5 -2 -1.5 -1 -0.5 0]

  (seq [i :range [0 6]
        :let [y (math/pow i 3)]]
    y)
  # =>
  @[0 1 8 27 64 125]

  (do
    (def buf @"")
    (flatten
      (seq [i :range [0 3]
            :before (buffer/push-string buf "!")]
        [(string buf) i])))
  # =>
  @["!" 0 "!!" 1 "!!!" 2]

  (do
    (def buf @"")
    (flatten
      (seq [i :range [0 3]
            :after (buffer/push-string buf "!")]
        [(string buf) i])))
  # =>
  @["" 0 "!" 1 "!!" 2]

  (seq [i :range-to [1 3]
        :repeat i]
    i)
  # =>
  @[1 2 2 3 3 3]

  )
