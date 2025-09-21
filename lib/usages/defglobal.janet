(comment

  (do
    (defn my-fn
      []
      (defglobal 'a 1))

    (my-fn)

    # note: after the enclosing `do`, `a` will evaluate to 1
    ((dyn 'a) :value))
  # =>
  1

  )
