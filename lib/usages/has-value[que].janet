(comment

  (has-value? @{:key1 "foo" :key2 "bar"} "foo")
  # =>
  true

  (has-value? "abc" 97)
  # =>
  true

  (has-value? ["a" "b" "c"] "a")
  # =>
  true

  (has-value? @{} 0)
  # =>
  false

  (has-value? @{:key1 "foo" :key2 "bar"} "hello")
  # =>
  false

  (has-value? @{:key1 "foo" :key2 "bar"} nil)
  # =>
  false

  (has-value? {} 0)
  # =>
  false

  (has-value? {:key1 "foo" :key2 "bar"} "foo")
  # =>
  true

  (has-value? {:key1 "foo" :key2 "bar"} "hello")
  # =>
  false

  (has-value? {:key1 "foo" :key2 "bar"} nil)
  # =>
  false

  (has-value? "" 0)
  # =>
  false

  (has-value? "" nil)
  # =>
  false

  (has-value? "abc" "a")
  # =>
  false

  (has-value? "abc" 'a)
  # =>
  false

  # tuples
  (has-value? [] 0)
  # =>
  false

  (has-value? ["a" "b" "c"] 'a)
  # =>
  false

  (has-value? ["a" "b" "c"] 97)
  # =>
  false

  (has-value? @[] 0)
  # =>
  false

  (has-value? @["a" "b" "c"] "a")
  # =>
  true

  (has-value? @["a" "b" "c"] 'a)
  # =>
  false

  (has-value? @["a" "b" "c"] 97)
  # =>
  false

  )

