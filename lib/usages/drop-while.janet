(comment

  (drop-while even? [1 2 3])
  # =>
  [1 2 3]

  (drop-while |(number? (scan-number $))
              ["2r111" "0x08" "8r11" "10"])
  # =>
  []

  (drop-while odd? "aaaaatract")
  # =>
  "tract"

  (drop-while even? ":foo!")
  # =>
  "oo!"

  (drop-while nil [])
  # =>
  []

  )


