(comment

  (label here
    (for i 0 2
      (when (pos? i)
        (return here i))))
  # =>
  1

  (label here
    (def x :unreturned)
    (for i 0 2
      (for j 0 2
        (when (and (pos? i) (pos? j))
          (return here [i j]))))
    x)
  # =>
  [1 1]

  )
