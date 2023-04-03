(comment

  (prompt :fun
    (for i 0 2
      (when (pos? i)
        (return :fun i))))
  # =>
  1

  (do
    (defn l
      []
      (return :label :left))

    (defn r
      []
      (return :label :right))

    (defn m
      []
      (if true
        (l)
        (r))
      :never-reached)

    (prompt :label
      (m)))
  # =>
  :left

  )

