(comment

  (buffer? @"hello")
  # =>
  true

  (buffer?
    @``
     even long-buffers
     are buffers
     ``)
  # =>
  true

  (buffer? "")
  # =>
  false

  (buffer? (buffer "hi"))
  # =>
  true

  )
