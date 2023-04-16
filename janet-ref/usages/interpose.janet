(comment

  (interpose ", " ["ant" "bee" "cheetah"])
  # =>
  @["ant" ", " "bee" ", " "cheetah"]

  (interpose ":" ["/usr/local/bin" "/usr/bin" "/bin"])
  # =>
  @["/usr/local/bin" ":" "/usr/bin" ":" "/bin"]

  )


