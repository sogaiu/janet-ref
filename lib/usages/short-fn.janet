(comment

  ((fn [n] (+ n n)) 10)
  # =>
  20

  ((short-fn (+ $ $)) 10)
  # =>
  20

  (|(+ $ $) 10)
  # =>
  20

  (|(+ $0 $0) 10)
  # =>
  20

  (|(string $0 $1) "hi" "ho")
  # =>
  "hiho"

  (|(apply + $&) 1 2 3)
  # =>
  6

  (|{:a 1})
  # =>
  {:a 1}

  (|(= $ 1) 1)
  # =>
  true

  (|[1 2])
  # =>
  [1 2]

  (|@[8 9])
  # =>
  @[8 9]

  (|@(:fun :time))
  # =>
  @[:fun :time]

  (|{:a 1})
  # =>
  {:a 1}

  (|@{:pose :sit})
  # =>
  @{:pose :sit}

  (|'(0))
  # =>
  [0]

  (|~(:x))
  # =>
  [:x]

  (|:kwd)
  # =>
  :kwd

  (let [a-sym 1]
    (|a-sym))
  # =>
  1

  (|"a-str")
  # =>
  "a-str"

  (|@"buffer")
  # =>
  @"buffer"

  (|``long-string``)
  # =>
  "long-string"

  (|@``long-buffer``)
  # =>
  @"long-buffer"

  (|false)
  # =>
  false

  (|nil)
  # =>
  nil

  (|8)
  # =>
  8

  ((||8))
  # =>
  8

  (((|||8)))
  # =>
  8

  (|())
  # =>
  []

  )

