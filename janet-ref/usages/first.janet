(comment

  (first [:a :b :c])
  # =>
  :a

  (first [])
  # =>
  nil

  (first @[0 1 2])
  # =>
  0

  (first {:a 1 :b 2})
  # =>
  nil

  (first "hello")
  # =>
  (chr "h")

  (first nil)
  # =>
  nil

  (first :hooooo)
  # =>
  (chr "h")

  (first 32767)
  # =>
  nil

  )
