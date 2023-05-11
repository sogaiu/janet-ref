(comment

  (bytes? "a-string")
  # =>
  true

  (bytes? 'a-symbol)
  # =>
  true

  (bytes? :a-keyword)
  # =>
  true

  (bytes? @"a-buffer")
  # =>
  true

  (bytes? nil)
  # =>
  false

  (bytes? math/nan)
  # =>
  false

  (bytes? [:a :b :c])
  # =>
  false

  )
