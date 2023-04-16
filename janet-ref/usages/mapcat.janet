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

  (->> [[:a 1] [:b 2] [:c 3]]
       (mapcat identity)
       splice
       table)
  # =>
  @{:a 1 :b 2 :c 3}

  )


