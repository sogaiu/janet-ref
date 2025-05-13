(comment

  (map string [1 2 3])
  # =>
  @["1" "2" "3"]

  (map scan-number ["2r111" "0x08" "8r11" "10"])
  # =>
  @[7 8 9 10]

  (map identity [["alice" 1] ["bob" 2] ["carol" 3]])
  # =>
  @[["alice" 1] ["bob" 2] ["carol" 3]]

  (->> [[:a 1 ":)"] [:b 2 ":("] [:c 3 ":o"]]
       (map (fn [[k _ v]]
              [k v]))
       flatten
       splice
       table)
  # =>
  @{:a ":)"
    :b ":("
    :c ":o"}

  (map array [:x :y] [-1 1])
  # =>
  @[@[:x -1] @[:y 1]]

  (map |(pos? (+ ;$&)) [1 2 3] [-1 -2 -3] [0 1])
  # =>
  @[false true]

  )

