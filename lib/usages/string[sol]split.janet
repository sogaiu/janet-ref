(comment

  (string/split " " "hello there friend")
  # =>
  @["hello" "there" "friend"]

  (string/split "," "ant,bee,fox,elephant")
  # =>
  @["ant" "bee" "fox" "elephant"]

  (string/split "," "ant,bee,fox,elephant" 7)
  # =>
  @["ant,bee" "fox" "elephant"]

  (string/split "," "ant,bee,fox,elephant" 7 2)
  # =>
  @["ant,bee" "fox,elephant"]

  )
