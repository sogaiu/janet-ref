(comment

  (indexed? @[:a :b])
  # =>
  true

  (indexed? [8 9 11])
  # =>
  true

  (indexed? (freeze @["one" "step" "at" "a"]))
  # =>
  true

  (indexed? (seq [i :range [0 3]]
              (math/pow i 2)))
  # =>
  true

  (indexed? "a string")
  # =>
  false

  (indexed? @"a buffer")
  # =>
  false

  (indexed? :a-keyword)
  # =>
  false

  (indexed? 'a-symbol)
  # =>
  false

  (indexed? nil)
  # =>
  false

  (indexed? @{})
  # =>
  false

  (indexed? {})
  # =>
  false


  )
