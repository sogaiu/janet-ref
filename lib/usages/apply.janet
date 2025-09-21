(comment

  (apply + (range 10))
  # =>
  45

  (apply + [])
  # =>
  0

  (apply + 1 2 3 4 5 6 7 [8 9 10])
  # =>
  55

  (def [ok? value] (protect (apply + 1 2 3 4 5 6 7 8 9 10)))
  # =>
  [false "expected array or tuple, got 10"]

  (let [mx (apply for 'x 0 10 ['(print x)])]
    (and (= (length mx) 4)
         (= (get mx 0) 'do)
         (= (get-in mx [1 0]) 'var)
         (= (get-in mx [2 0]) 'def)
         (= (get-in mx [3 0]) 'while)))
  # =>
  true

  )

