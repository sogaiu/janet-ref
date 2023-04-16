(comment

  (if-with [f (file/open `/\`)]
    (eprint "Unexpected success")
    :an-ordinary-system)
  # =>
  :an-ordinary-system

  )
