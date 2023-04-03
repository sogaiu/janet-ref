(comment

  (or)
  # =>
  nil

  (or 1)
  # =>
  1

  (or nil 1)
  # =>
  1

  (or nil (/ 2 1) false)
  # =>
  2

  (or false false false nil)
  # =>
  nil

  )
