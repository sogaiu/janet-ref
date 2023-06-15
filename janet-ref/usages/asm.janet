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

  ((asm '{:bytecode @[(band 0 0 1)
                      (ret 0)]
          :arity 2})
    2r101 2r111)
  # =>
  2r101

  ((asm '{:bytecode @[(bnot 0 0)
                      (ret 0)]
          :arity 1})
    2r101)
  # =>
  (- (inc 2r101))

  ((asm '{:bytecode @[(bor 0 0 1)
                      (ret 0)]
          :arity 2})
    2r11110000 2r00001111)
  # =>
  2r11111111

  ((asm '{:bytecode @[(bxor 0 0 1)
                      (ret 0)]
          :arity 2})
    2r00110011 2r00001111)
  # =>
  2r00111100

  ((asm ~{:constants [,type]
          :bytecode @[(push 0)
                      (ldc 1 0)
                      (call 0 1)
                      (ret 0)]
          :arity 1})
    :smile)
  # =>
  :keyword

  ((asm ~{:defs @[,(disasm (asm '{:arity 1
                                  :bytecode @[(addim 1 0 8)
                                              (ret 1)]}))]
          :bytecode @[(push 0)
                      (clo 0 0)
                      (call 1 0)
                      (ret 1)]
          :arity 1})
    3)
  # =>
  11

  ((asm ~{:bytecode @[(cmp 2 0 1)
                      (ret 2)]
          :arity 2})
    -11 22)
  # =>
  -1

  (try
    ((asm ~{:bytecode @[(cncl 2 0 1)
                        (ret 2)]
            :arity 2})
      (coro 1) "Oops!")
    ([e]
      (string "Ah..." e)))
  # =>
  "Ah...Oops!"

  ((asm ~{:bytecode @[(div 2 0 1)
                      (ret 2)]
          :arity 2})
    1 0)
  # =>
  math/inf

  ((asm ~{:bytecode @[(divim 2 0 2)
                      (ret 2)]
          :arity 1})
    1)
  # =>
  0.5

  (try
    ((asm ~{:bytecode @[(err 0)]
            :arity 1})
      "at you!")
    ([e]
      (string "Have " e)))
  # =>
  "Have at you!"

  ((asm ~{:bytecode @[(get 2 0 1)
                      (ret 2)]
          :arity 2})
    {:a 1} :a)
  # =>
  1

  ((asm ~{:bytecode @[(geti 2 0 2)
                      (ret 2)]
          :arity 1})
    [0 1 8])
  # =>
  8

  ((asm ~{:bytecode @[(gt 2 0 1)
                      (ret 2)]
          :arity 2})
    0 88)
  # =>
  false

  ((asm ~{:bytecode @[(gte 2 0 1)
                      (ret 2)]
          :arity 2})
    88 88)
  # =>
  true

  ((asm ~{:bytecode @[(gtim 1 0 0x57)
                      (ret 1)]
          :arity 1})
    88)
  # =>
  true

  ((asm ~{:bytecode @[(in 2 0 1)
                      (ret 2)]
          :arity 2})
    {:x :spot} :x)
  # =>
  :spot

  ((asm ~{:bytecode @[(jmp 3)
                      (ldi 0 8)
                      (ret 0)
                      (ldi 0 9)
                      (ret 0)]
          :arity 0}))
  # =>
  9

  ((asm ~{:bytecode @[(jmpif 0 2)
                      (ret 1)
                      (ret 2)]
          :arity 3})
    true :ant :bee)
  # =>
  :bee

  ((asm ~{:bytecode @[(jmpni 0 2)
                      (ret 1)
                      (ret 2)]
          :arity 3})
    true :ant :bee)
  # =>
  :ant

  ((asm ~{:bytecode @[(jmpnn 0 2)
                      (ret 1)
                      (ret 2)]
          :arity 3})
    true :ant :bee)
  # =>
  :bee

  ((asm ~{:bytecode @[(jmpno 0 2)
                      (ret 1)
                      (ret 2)]
          :arity 3})
    true :ant :bee)
  # =>
  :ant

  ((asm ~{:constants [:grin]
          :bytecode @[(ldc 0 0)
                      (ret 0)]
          :arity 0}))
  # =>
  :grin

  ((asm ~{:bytecode @[(ldf 0)
                      (ret 0)]
          :arity 0}))
  # =>
  false

  ((asm ~{:bytecode @[(ldi 0 0x100)
                      (ret 0)]
          :arity 0}))
  # =>
  256

  ((asm ~{:bytecode @[(ldn 0)
                      (ret 0)]
          :arity 0}))
  # =>
  nil

  # factorial with accumulator
  ((asm ~{:bytecode @[(ltim 2 0 2)
                      (jmpif 2 :end)
                      (lds 2)
                      (mul 1 0 1)
                      (addim 0 0 -0x1)
                      (push2 0 1)
                      (call 1 2)
                      :end
                      (ret 1)]
          :arity 2})
    5 1)
  # =>
  120

  )
