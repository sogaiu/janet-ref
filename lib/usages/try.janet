(comment

  (try
    :success
    ([_]
      nil))
  # =>
  :success

  (try
    (error "ouch")
    ([err]
      err))
  # =>
  "ouch"

  (try
    (error "extra")
    ([_ fib]
      (type fib)))
  # =>
  :fiber

  )
