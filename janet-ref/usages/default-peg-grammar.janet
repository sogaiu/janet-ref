(comment

  (table? default-peg-grammar)
  # =>
  true

  (>= (length default-peg-grammar) 20)
  # =>
  true

  (default-peg-grammar :s)
  # =>
  '(set " \t\r\n\0\f\v")

  (default-peg-grammar :s+)
  # =>
  '(some :s)

  (default-peg-grammar :s*)
  # =>
  '(any :s)

  (default-peg-grammar :S)
  # =>
  '(if-not :s 1)

  (default-peg-grammar :j)
  # =>
  nil

  )
