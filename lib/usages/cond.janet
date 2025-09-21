(comment

  (cond
    true
    :hi)
  # =>
  :hi

  (cond
    false
    :not-reached
    #
    true
    :hello)
  # =>
  :hello

  (cond
    :why)
  # =>
  :why

  (cond
    (= 1 2)
    :not-today
    #
    (= 2 3)
    :not-ever
    #
    :because)
  # =>
  :because

  (cond
    false
    :not-returned)
  # =>
  nil

  )
