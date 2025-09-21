(comment

  (do
    (var tot 3)
    (tabseq [i :iterate (when (pos? (-- tot)) tot)]
      i (math/pow i 3)))
  # =>
  @{1 1
    2 8}

  (tabseq [i :range [0 4]]
    i (math/pow i 2))
  # =>
  @{0 0
    1 1
    2 4
    3 9}

  (tabseq [i :range [0 4 2]]
    i (* -1 i))
  # =>
  @{0 0
    2 -2}

  (tabseq [i :range-to [8 12]]
    i (even? i))
  # =>
  @{8 true
    9 false
    10 true
    11 false
    12 true}

  (tabseq [i :range-to [8 12 2]]
    i (even? i))
  # =>
  @{8 true
    10 true
    12 true}

  (tabseq [j :down [10 0]]
    (even? j) j)
  # =>
  @{false 1
    true 2}

  (tabseq [j :down [10 0 2]]
    (even? j) j)
  # =>
  @{true 2}

  (tabseq [j :down-to [3 -3]]
    (pos? j) j)
  # =>
  @{false -3
    true 1}

  (tabseq [j :down-to [3 -3 3]]
    (pos? j) j)
  # =>
  @{false -3
    true 3}

  (tabseq [k :keys {:a 1 :b 2}]
    k (keyword (string/ascii-upper k)))
  # =>
  @{:a :A
    :b :B}

  (tabseq [[k v] :pairs {:a 1 :b 2}]
    v k)
  # =>
  @{1 :a
    2 :b}

  (tabseq [i :in [0 1 2]]
    i (math/pow i 3))
  # =>
  @{0 0
    1 1
    2 8}

  (tabseq [i :in (fiber/new
                   |(each x (range 3)
                      (yield x)))]
    i (math/pow i 3))
  # =>
  @{0 0
    1 1
    2 8}

  (tabseq [i :range [-3 3 0.5]
           :while (not (pos? i))]
    i (math/pow i 2))
  # =>
  @{-3   9
    -2.5 6.25
    -2   4
    -1.5 2.25
    -1   1
    -0.5 0.25
    -0   0}

  (tabseq [i :range [-3 3 0.5]
           :until (pos? i)]
    i (math/pow i 2))
  # =>
  @{-3   9
    -2.5 6.25
    -2   4
    -1.5 2.25
    -1   1
    -0.5 0.25
    -0   0}

  (tabseq [i :range [0 6]
           :let [c (math/pow i 3)]]
    i c)
  # =>
  @{0 0
    1 1
    2 8
    3 27
    4 64
    5 125}

  (do
    (def buf @"")
    (tabseq [i :range [0 3]
             :before (buffer/push-string buf "!")]
      i (string buf)))
  # =>
  @{0 "!"
    1 "!!"
    2 "!!!"}

  (do
    (def buf @"")
    (tabseq [i :range [0 3]
             :after (buffer/push-string buf "!")]
      i (string buf)))
  # =>
  @{0 ""
    1 "!"
    2 "!!"}

  (tabseq [i :range-to [1 3]
           :repeat i]
    (even? i) i)
  # =>
  @{false 3
    true 2}

  )
