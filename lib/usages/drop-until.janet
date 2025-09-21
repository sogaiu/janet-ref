(comment

  (drop-until even? [1 2 3])
  # =>
  [2 3]

  (drop-until |(number? (scan-number $))
              ["2r111" "0x08" "8r11" "10"])
  # =>
  ["2r111" "0x08" "8r11" "10"]

  (drop-until odd? "hi")
  # =>
  "i"

  (drop-until even? :smilet)
  # =>
  "let"

  (drop-until nil [])
  # =>
  []

  )


