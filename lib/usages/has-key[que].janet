(comment

  (has-key? @{:key1 "foo" :key2 "bar"} :key1)
  # =>
  true

  (has-key? "a" 0)
  # =>
  true

  (has-key? ["a" "b" "c"] 1)
  # =>
  true

  (has-key? @{} 0)
  # =>
  false

  (has-key? @{:key1 "foo" :key2 "bar"} :key3)
  # =>
  false

  (has-key? {} 0)
  # =>
  false

  (has-key? {:key1 "foo" :key2 "bar"} :key1)
  # =>
  true

  (has-key? {:key1 "foo" :key2 "bar"} :key3)
  # =>
  false

  (has-key? "" 0)
  # =>
  false

  (has-key? "a" 1)
  # =>
  false

  (has-key? [] 0)
  # =>
  false

  (has-key? ["a" "b" "c"] 4)
  # =>
  false

  (has-key? @[] 0)
  # =>
  false

  (has-key? @["a" "b" "c"] 1)
  # =>
  true

  (has-key? @["a" "b" "c"] 4)
  # =>
  false

  )

