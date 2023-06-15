(comment

  (do
    (def code
      '{:bytecode @[(ldi 1 2)    # $1 = 2
                    (mul 2 0 1)  # $2 = $0 + $1
                    (ret 2)]     # return $2
        :arity 1})               # arg 0 is $0
    (def double
      (asm code))
    (double 3))
  # =>
  6

  (do
    (def code
      '{:bytecode @[(add 2 0 1)  # $2 = $0 + $1
                    (ret 2)]     # return $2
        :arity 2})               # args 0 and 1 are $0 and $1
    (def add
      (asm code))
    (add 1 2))
  # =>
  3

  (do
    (def code
      '{:bytecode @[(ldi 1 1)    # $1 = 1
                    (add 2 0 1)  # $2 = $0 + $1
                    (ret 2)]     # return $2
        :arity 1})               # arg 0 is $0
    (def my-inc
      (asm code))
    (my-inc 7))
  # =>
  8

  (do
    (def code
      '{:bytecode @[(addim 1 0 1)  # $1 = $0 + 1
                    (ret 1)]       # return $1
        :arity 1})                 # arg 0 is $0
    (def my-inc-2
      (asm code))
    (my-inc-2 7))
  # =>
  8

  (do
    (def code
      # janet/test/suite-asm.janet
      '{:bytecode @[(ltim 1 0 0x2)    # $1 = $0 < 2
                    (jmpif 1 :done)   # if ($1) goto :done
                    (lds 1)           # $1 = self
                    (addim 0 0 -0x1)  # $0 = $0 - 1
                    (push 0)          # push($0), for next func call
                    (call 2 1)        # $2 = call($1)
                    (addim 0 0 -0x1)  # $0 = $0 - 1
                    (push 0)          # push($0)
                    (call 0 1)        # $0 = call($1)
                    (add 0 0 2)       # $0 = $0 + $2
                    :done
                    (ret 0)]          # return $0
        :arity 1})
    (def fib
      (asm code))
    (fib 6))
  # =>
  8

  )
