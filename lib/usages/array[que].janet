(comment

  (array? @[:a :b])
  # =>
  true

  (array? @(:x :y :z))
  # =>
  true

  (array? (accumulate + 0 [0 1 2]))
  # =>
  true

  (array? (accumulate2 + [0 1 2]))
  # =>
  true

  (array? (debug/arg-stack (fiber/current)))
  # =>
  true

  (array? (debug/lineage (fiber/root)))
  # =>
  true

  (array? (debug/stack (fiber/current)))
  # =>
  true

  (array? (disasm (fn [] :dolphin) :bytecode))
  # =>
  true

  (array? (disasm (fn [] :dolphin) :constants))
  # =>
  true

  (array? (distinct [1 1 2 2]))
  # =>
  true

  (array? (ev/gather (coro 1) (coro 2)))
  # =>
  true

  (array? (filter odd? [-1 0 1]))
  # =>
  true

  (array? (flatten [:x [:y {:z 1}]]))
  # =>
  true

  (array? (flatten-into @[] [:x [:y {:z 1}]]))
  # =>
  true

  (array? (interleave [1 2 3] [:one :two :three]))
  # =>
  true

  (array? (interpose "," [:a :b :c]))
  # =>
  true

  (array? (keep |(when (odd? $)
                   (string $))
                [1 2 3]))
  # =>
  true

  (array? (kvs {:a 1 :b 2}))
  # =>
  true

  (array? (map inc [-2 -1 0]))
  # =>
  true

  (array? (mapcat sum [[1 8] [2 7] [0 9]]))
  # =>
  true

  (array? (os/dir "."))
  # =>
  true

  (array? (partition 2 [0 1 2 3]))
  # =>
  true

  (array? (partition-by even? [0 1 2 3 7 8 9]))
  # =>
  true

  (array? (peg/find-all "a" "abba"))
  # =>
  true

  (array? (peg/match '(sequence (thru ".")) "hello there."))
  # =>
  true

  (array? (peg/match '(sequence (thru ".")) "hello there?"))
  # =>
  false

  (array? (put @[] 0 1))
  # =>
  true

  (array? (put-in @[@[]] [0 0] :treasure))
  # =>
  true

  (array? (range 0 3))
  # =>
  true

  (array? (reverse @[0 1 2]))
  # =>
  true

  (array? (reverse! @[math/pi math/e]))
  # =>
  true

  (array? (seq [i :in [0 1 2]] i))
  # =>
  true

  (array? (sorted @[3 math/pi math/e]))
  # =>
  true

  (array? (sorted-by math/abs @[-2 1 2 -1 0]))
  # =>
  true

  (array? (string/find-all "/" "/usr/local/src"))
  # =>
  true

  (array? (string/split "/" "/usr/local/src"))
  # =>
  true

  (array? (take 2 (coro
                    (yield :alice)
                    (yield :bob))))
  # =>
  true

  (array? (take-until even?
                      (coro
                        (yield 1)
                        (yield 2))))
  # =>
  true

  (array? (take-while even?
                      (coro
                        (yield 2)
                        (yield 8)
                        (yield 9))))
  # =>
  true

  (array? [])
  # =>
  false

  (array? '())
  # =>
  false

  )
