(comment

  (prompt :there
    (for i 0 2
      (for j 0 2
        (when (and (pos? i) (pos? j))
          (return :there [i j])))))
  # =>
  [1 1]

  (label there
    (def z :not-returned)
    (for i 0 2
      (for j 0 2
        (when (and (pos? i) (pos? j))
          (return there [i j]))))
    z)
  # =>
  [1 1]

  )
