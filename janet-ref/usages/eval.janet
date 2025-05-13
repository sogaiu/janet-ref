(comment

  (eval '(+ 1 2 3)) 
  # =>
  6

  (def [ok? value] 
    (-> (eval '(error :oops))
        protect))
  # =>
  [false :oops]

  (def [ok? value] 
    (-> (eval '(+ nil nil))
        protect))
  # =>
  [false "could not find method :+ for nil or :r+ for nil"]

  )

