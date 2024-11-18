(comment

  (do
    (var tot 3)
    (def fib
      (generate [i :iterate (when (pos? (-- tot)) tot)]
        (math/pow i 3)))
    [(resume fib) (resume fib)])
  # =>
  [8 1]

  (do
    (def fib
      (generate [i :range [0 4]]
        (math/pow i 2)))
    (resume fib)
    @[(resume fib)
      (resume fib)
      (resume fib)])
  # =>
  @[1 4 9]

  (do
    (def fib
      (generate [i :range [0 4 2]]
        (* -1 i)))
    (resume fib)
    (resume fib))
  # =>
  -2

  (do
    (def fib
      (generate [i :range-to [8 12]]
        i))
    (resume fib)
    (filter even? fib))
  # =>
  @[10 12]

  (do
    (def fib
      (generate [i :range-to [8 12 2]]
        i))
    (resume fib)
    (resume fib))
  # =>
  10

  (do
    (def fib
      (generate [j :down [10 0]]
        j))
    (resume fib)
    (resume fib)
    (resume fib))
  # =>
  8

  (do
    (def fib
      (generate [j :down [10 0 2]]
        j))
    (resume fib)
    (resume fib))
  # =>
  8

  (do
    (def fib
      (generate [j :down-to [3 -3]]
        j))
    (resume fib)
    (resume fib))
  # =>
  2

  (do
    (def fib
      (generate [j :down-to [3 -3 3]]
        j))
    (resume fib)
    (resume fib))
  # =>
  0

  (do
    (def fib
      (generate [k :keys {:a 1 :b 2}]
        (keyword (string/ascii-upper k))))
    (sort @[(resume fib) (resume fib)]))
  # =>
  @[:A :B]

  (do
    (def fib
      (generate [[k v] :pairs {:a 1 :b 2}]
        [v k]))
    (table ;(resume fib) ;(resume fib)))
  # =>
  @{1 :a
    2 :b}

  (do
    (def fib
      (generate [i :in [0 1 2]]
        (math/pow i 3)))
    (resume fib)
    [(resume fib) (resume fib)])
  # =>
  [1 8]

  (do
    (def fib
      (generate [i :in (fiber/new
                         |(each x (range 3)
                            (yield x)))]
        (math/pow i 3)))
    (resume fib)
    (+ (resume fib) (resume fib)))
  # =>
  9

  (do
    (def fib
      (generate [i :range [-3 3 0.5]
                 :while (not (pos? i))]
        (math/pow i 2)))
    (resume fib)
    [(resume fib) (+ (resume fib) (resume fib))])
  # =>
  [6.25 6.25]

  (do
    (def fib
      (generate [i :range [-3 3 0.5]
                 :until (pos? i)]
        (math/pow i 2)))
    (resume fib)
    [(resume fib) (+ (resume fib) (resume fib))])
  # =>
  [6.25 6.25]

  (do
    (def fib
      (generate [i :range [0 6]
                 :let [c (math/pow i 3)]]
        c))
    (resume fib)
    (+ (resume fib) (resume fib)
       (* 0 (resume fib))
       (resume fib)))
  # =>
  73

  (do
    (def buf @"")
    (def fib
      (generate [i :range [0 3]
                 :before (buffer/push-string buf "!")]
        (string buf)))
    (def [head _ tail]
      [(resume fib) (resume fib) (resume fib)])
    [head tail])
  # =>
  ["!" "!!!"]

  (do
    (def buf @"")
    (def fib
      (generate [i :range [0 3]
                 :after (buffer/push-string buf "!")]
        (string buf)))
    (def [head _ tail]
      [(resume fib) (resume fib) (resume fib)])
    [head tail])
  # =>
  ["" "!!"]

  (do
    (def fib
      (generate [i :range-to [1 3]
                 :repeat i]
        i))
    (repeat 4
      (resume fib))
    (resume fib))
  # =>
  3

  )
