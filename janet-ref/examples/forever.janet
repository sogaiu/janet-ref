(comment

  (do
    (var i 0)
    (forever
      (when (pos? i)
        (break))
      (++ i))
    i)
  # =>
  1

  )
