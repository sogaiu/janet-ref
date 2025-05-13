(comment

  (eval-string "(+ 1 2 3 4)")
  # =>
  10

  (def [ok? value]
    (-> (eval-string ")")
        protect))
  # =>
  [false "unexpected closing delimiter )"]

  (def [ok? value]
    (-> (eval-string "(bloop)")
        protect))
  # =>
  [false "unknown symbol bloop"]

  (def [ok? value]
    (-> (eval-string "(+ nil nil)")
        protect))
  # =>
  [false "could not find method :+ for nil or :r+ for nil"]

  )

