(comment

  (last [:a :b :c])
  # =>
  :c

  (last [])
  # =>
  nil

  (last @[0 1 2])
  # =>
  2

  (last {:a 1 :b 2})
  # =>
  nil

  (last "hello")
  # =>
  (chr "o")

  (->> (try
         (last nil)
         ([e]
           e))
       (string/find "expected")
       truthy?)
  # =>
  true

  (last :hooooo)
  # =>
  (chr "o")

  (->> (try
         (last 32767)
         ([e]
           e))
       (string/find "expected")
       truthy?)
  # =>
  true

  )
