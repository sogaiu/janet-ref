(comment

  (prompt :fun
    (for i 0 2
      (when (pos? i)
        (return :fun i))))
  # =>
  1

  (prompt :here
    (for i 0 2
      (for j 0 2
        (when (and (pos? i) (pos? j))
          (return :here [i j])))))
  # =>
  [1 1]

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

