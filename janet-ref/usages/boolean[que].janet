(comment

  (boolean? true)
  # =>
  true

  (boolean? false)
  # =>
  true

  (boolean? nil)
  # =>
  false

  (boolean? 0)
  # =>
  false

  (boolean? (< 0 1))
  # =>
  true

  (boolean? (<= 2 1))
  # =>
  true

  (boolean? (= math/pi math/e))
  # =>
  true

  (boolean? (> math/inf math/-inf))
  # =>
  true

  (boolean? (>= 0 0))
  # =>
  true

  (boolean? (abstract? nil))
  # =>
  true

  (boolean? (all even? [0 2 8]))
  # =>
  true

  (boolean? (all |(when (even? $))
                 [0 3 8]))
  # =>
  false

  (boolean? (and true false))
  # =>
  true

  (boolean? (and true nil))
  # =>
  false

  (boolean? (any? [true nil]))
  # =>
  true

  (boolean? (any? [nil]))
  # =>
  false

  (boolean? (array? @[]))
  # =>
  true

  (boolean? (array? :a))
  # =>
  true

  (boolean? (buffer/bit @"1" 0))
  # =>
  true

  (boolean? (buffer/bit @"1" 1))
  # =>
  true

  (boolean? (buffer? @""))
  # =>
  true

  (boolean? (bytes? []))
  # =>
  true

  (boolean? (cfunction? :a))
  # =>
  true

  (boolean? (compare< 1 2))
  # =>
  true

  (boolean? (compare<= -1 -2))
  # =>
  true

  (boolean? (compare= 0 0.0))
  # =>
  true

  (boolean? (compare> -0 1))
  # =>
  true

  (boolean? (compare>= math/-inf math/inf))
  # =>
  true

  (boolean? (deep-not= [:a] [:b]))
  # =>
  true

  (boolean? (deep= [:a] [:b]))
  # =>
  true

  (boolean? (dictionary? "hello"))
  # =>
  true

  (boolean? (disasm (fn [] 9) :vararg))
  # =>
  true

  (boolean? (empty? :smile))
  # =>
  true

  (boolean? (even? math/nan))
  # =>
  true

  (boolean? (false? false))
  # =>
  true

  (boolean? (false? true))
  # =>
  true

  (boolean? (fiber/can-resume? (coro 1)))
  # =>
  true

  (boolean? (fiber? (coro :breathe)))
  # =>
  true

  (boolean? (function? map))
  # =>
  true

  (boolean? (idempotent? false))
  # =>
  true

  (boolean? (keyword? 'fun))
  # =>
  true

  (boolean? (nan? 0))
  # =>
  true

  (boolean? (nat? math/nan))
  # =>
  true

  (boolean? (neg? math/inf))
  # =>
  true

  (boolean? (nil? 1))
  # =>
  true

  (boolean? (not 1))
  # =>
  true

  (boolean? (not= 0.0 0))
  # =>
  true

  (boolean? (number? "hi"))
  # =>
  true

  (boolean? (odd? 2))
  # =>
  true

  (boolean? (one? 1.1))
  # =>
  true

  (boolean? (parse "true"))
  # =>
  true

  (boolean? (parse "nil"))
  # =>
  false

  (boolean? (pos? -3))
  # =>
  true

  (boolean? (string/check-set "abcdr " "abra cadabra"))
  # =>
  true

  (boolean? (string/has-prefix? "/" "/tmp"))
  # =>
  true

  (boolean? (string/has-suffix? ".txt" "README.txt"))
  # =>
  true

  (boolean? (string? "my my"))
  # =>
  true

  (boolean? (struct? {:ant :zebra}))
  # =>
  true

  (boolean? (symbol? :a-keyword))
  # =>
  true

  (boolean? (table? @{:x 1080 :y 720}))
  # =>
  true

  (boolean? (do
              (var x nil)
              (toggle x)))
  # =>
  true

  (boolean? (true? false))
  # =>
  true

  (boolean? (truthy? nil))
  # =>
  true

  (boolean? (tuple? @[:an :array]))
  # =>
  true

  (boolean? (zero? 0.1))
  # =>
  true

  )
