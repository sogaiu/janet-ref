(comment

  (mapcat string [1 2 3])
  # =>
  @["1" "2" "3"]

  (mapcat scan-number ["2r111" "0x08" "8r11" "10"])
  # =>
  @[7 8 9 10]

  (mapcat identity [["alice" 1] ["bob" 2] ["carol" 3]])
  # =>
  @["alice" 1 "bob" 2 "carol" 3]

  (mapcat tuple [:x :y] [-1 1])
  # =>
  @[:x -1 :y 1]

  (mapcat |(tuple $0 $1 $2) [:a :b] [:x :y :z] [0 1])
  # =>
  @[:a :x 0 :b :y 1]

  (->> [[:a 1] [:b 2] [:c 3]]
       (mapcat identity)
       splice
       table)
  # =>
  @{:a 1 :b 2 :c 3}

  )


