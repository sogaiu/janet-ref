(comment

  (do
    (var tot 3)
    (def arr @[])
    (loop [i :iterate (when (pos? (-- tot)) tot)]
      (array/push arr i))
    arr)
  # =>
  @[2 1]

  (do
    (def arr @[])
    (loop [i :range [0 4]]
      (array/push arr i))
    arr)
  # =>
  @[0 1 2 3]

  (do
    (def arr @[])
    (loop [i :range [0 4 2]]
      (array/push arr i))
    arr)
  # =>
  @[0 2]

  (do
    (def arr @[])
    (loop [i :range-to [8 12]]
      (array/push arr i))
    arr)
  # =>
  @[8 9 10 11 12]

  (do
    (def arr @[])
    (loop [i :range-to [8 12 2]]
      (array/push arr i))
    arr)
  # =>
  @[8 10 12]

  (do
    (def arr @[])
    (loop [j :down [10 0]]
      (array/push arr j))
    arr)
  # =>
  @[10 9 8 7 6 5 4 3 2 1]

  (do
    (def arr @[])
    (loop [j :down [10 0 2]]
      (array/push arr j))
    arr)
  # =>
  @[10 8 6 4 2]

  (do
    (def arr @[])
    (loop [j :down-to [3 -3]]
      (array/push arr j))
    arr)
  # =>
  @[3 2 1 0 -1 -2 -3]

  (do
    (def arr @[])
    (loop [j :down-to [3 -3 3]]
      (array/push arr j))
    arr)
  # =>
  @[3 0 -3]

  (do
    (def arr @[])
    (loop [k :keys {:a 1 :b 2}]
      (array/push arr k))
    (sort arr))
  # =>
  @[:a :b]

  (do
    (def arr @[])
    (loop [[k v] :pairs {:a 1 :b 2}]
      (array/push arr v)
      (array/push arr k))
    (table ;arr))
  # =>
  @{1 :a 2 :b}

  (do
    (def arr @[])
    (def nums [0 1 2])
    (loop [i :in nums]
      (array/push arr (math/pow i 3)))
    (sort arr))
  # =>
  @[0 1 8]

  (do
    (def arr @[])
    (def fib
      (fiber/new
        |(each x (range 3)
           (yield x))))
    (loop [i :in fib]
      (array/push arr (math/pow i 3)))
    arr)
  # =>
  @[0 1 8]

  (do
    (def arr @[])
    (loop [i :range [-3 3 0.5]
           :while (not (pos? i))]
      (array/push arr i))
    arr)
  # =>
  @[-3 -2.5 -2 -1.5 -1 -0.5 0]

  (do
    (def arr @[])
    (loop [i :range [-3 3 0.5]
           :until (pos? i)]
      (array/push arr i))
    arr)
  # =>
  @[-3 -2.5 -2 -1.5 -1 -0.5 0]

  (do
    (def arr @[])
    (loop [i :range [0 6]
           :let [y (math/pow i 3)]]
      (array/push arr y))
    arr)
  # =>
  @[0 1 8 27 64 125]

  (do
    (def arr @[])
    (def buf @"")
    (loop [i :range [0 3]
           :before (buffer/push-string buf "!")]
      (array/push arr (string buf))
      (array/push arr i))
    arr)
  # =>
  @["!" 0 "!!" 1 "!!!" 2]

  (do
    (def arr @[])
    (def buf @"")
    (loop [i :range [0 3]
           :after (buffer/push-string buf "!")]
      (array/push arr (string buf))
      (array/push arr i))
    arr)
  # =>
  @["" 0 "!" 1 "!!" 2]

  (do
    (def arr @[])
    (loop [i :range-to [1 3]
           :repeat i]
      (array/push arr i))
    arr)
  # =>
  @[1 2 2 3 3 3]

  )
