(comment

  (function? inc)
  # =>
  true

  (function? (fn [] :hi))
  # =>
  true

  (function? |(/ $ 3))
  # =>
  true

  (function? |[$ :tagged])
  # =>
  true

  (function? (partial + 2))
  # =>
  true

  (function? (juxt zero? one? even? odd? nan?))
  # =>
  true

  (and (function? defn)
       ((dyn 'defn) :macro))
  # =>
  true

  [(function? print) (cfunction? print)]
  # =>
  [false true]

  (function? (compile '(+ 1 1)))
  # =>
  true

  )
