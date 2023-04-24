(comment

  (symbol? 'print)
  # =>
  true

  (symbol? (symbol "my-sym"))
  # =>
  true

  (symbol? '*out*)
  # =>
  true

  (symbol? :keyword)
  # =>
  false

  (symbol? "i am a string")
  # =>
  false

  )
