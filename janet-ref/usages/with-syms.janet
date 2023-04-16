(comment

  (eval (with-syms [$my-sym]
          ~(do
             (def ,$my-sym 1)
             ,$my-sym)))
  # =>
  1

  (eval (with-syms [$my-a $my-i]
          ~(do
             (def ,$my-a @[])
             (for ,$my-i 0 2
               (array/push ,$my-a ,$my-i))
             ,$my-a)))
  # =>
  @[0 1]

  )
