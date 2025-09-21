(comment

  (do
    (def code
      '{:bytecode @[(ldi 1 0x2)  # $1 = 2
                    (mul 2 0 1)  # $2 = $0 * $1
                    (ret 2)]     # return $2
        :arity 1})               # arg 0 is $0
    (def double
      (asm code))
    (double 3))
  # =>
  6

  (do
    (def code
      '{:bytecode @[(ldi 1 0x1)  # $1 = 1
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

  # add: $dest = $lhs + $rhs
  ((asm '{:bytecode @[(add 2 0 1)  # $2 = $0 + $1
                      (ret 2)]     # return $2
          :arity 2})               # args 0 and 1 are $0 and $1
    1 2)
  # =>
  3

  # addim: $dest = $lhs + im
  ((asm '{:bytecode @[(addim 1 0 0x1)  # $1 = $0 + 1
                      (ret 1)]         # return $1
          :arity 1})                   # arg 0 is $0
    7)
  # =>
  8

  # band: $dest = $lhs & $rhs
  ((asm '{:bytecode @[(band 0 0 1)
                      (ret 0)]
          :arity 2})
    2r101 2r111)
  # =>
  2r101

  # bnot: $dest = ~$operand
  ((asm '{:bytecode @[(bnot 0 0)
                      (ret 0)]
          :arity 1})
    2r101)
  # =>
  (- (inc 2r101))

  # bor: $dest = $lhs | $rhs
  ((asm '{:bytecode @[(bor 0 0 1)
                      (ret 0)]
          :arity 2})
    2r11110000 2r00001111)
  # =>
  2r11111111

  # bxor: $dest = $lhs ^ $rhs
  ((asm '{:bytecode @[(bxor 0 0 1)
                      (ret 0)]
          :arity 2})
    2r00110011 2r00001111)
  # =>
  2r00111100

  # call: $dest = call($callee, args)
  ((asm ~{:constants [,type]
          :bytecode @[(push 0)
                      (ldc 1 0)
                      (call 0 1)
                      (ret 0)]
          :arity 1})
    :smile)
  # =>
  :keyword

  # clo: $dest = closure(defs[$index])
  ((asm ~{:defs @[,(disasm (asm '{:arity 1
                                  :bytecode @[(addim 1 0 0x8)
                                              (ret 1)]}))]
          :bytecode @[(push 0)
                      (clo 0 0)
                      (call 1 0)
                      (ret 1)]
          :arity 1})
    3)
  # =>
  11

  # cmp: $dest = janet_compare($lhs, $rhs)
  ((asm ~{:bytecode @[(cmp 2 0 1)
                      (ret 2)]
          :arity 2})
    -11 22)
  # =>
  -1

  # cncl: resume $fiber, but raise $error immediately
  (try
    ((asm ~{:bytecode @[(cncl 2 0 1)
                        (ret 2)]
            :arity 2})
      (coro 1) "Oops!")
    ([e]
      (string "Ah..." e)))
  # =>
  "Ah...Oops!"

  # div: $dest = $lhs / $rhs
  ((asm ~{:bytecode @[(div 2 0 1)
                      (ret 2)]
          :arity 2})
    1 0)
  # =>
  math/inf

  # divim: $dest = $lhs / im
  ((asm ~{:bytecode @[(divim 2 0 0x2)
                      (ret 2)]
          :arity 1})
    1)
  # =>
  0.5

  # eq: $dest = $lhs == $rhs
  ((asm ~{:bytecode @[(eq 2 0 1)
                      (ret 2)]
          :arity 2})
    1 0)
  # =>
  false

  # eqim: $dest = $lhs == im
  ((asm ~{:bytecode @[(eqim 2 0 0x1)
                      (ret 2)]
          :arity 1})
    1)
  # =>
  true

  # err: throw $error
  (try
    ((asm ~{:bytecode @[(err 0)]
            :arity 1})
      "at you!")
    ([e]
      (string "Have " e)))
  # =>
  "Have at you!"

  # get: $dest = $ds[$key]
  ((asm ~{:bytecode @[(get 2 0 1)  # (get dest ds key)
                      (ret 2)]
          :arity 2})
    {:a 1} :a)
  # =>
  1

  # geti: $dest = $ds[index]
  ((asm ~{:bytecode @[(geti 2 0 0x2)  # (geti dest ds index)
                      (ret 2)]
          :arity 1})
    [0 1 8])
  # =>
  8

  # gt: $dest = $lhs > $rhs
  ((asm ~{:bytecode @[(gt 2 0 1)
                      (ret 2)]
          :arity 2})
    0 88)
  # =>
  false

  # gte: $dest = $lhs >= $rhs
  ((asm ~{:bytecode @[(gte 2 0 1)
                      (ret 2)]
          :arity 2})
    88 88)
  # =>
  true

  # gtim: $dest = $lhs > im
  ((asm ~{:bytecode @[(gtim 1 0 0x57)
                      (ret 1)]
          :arity 1})
    88)
  # =>
  true

  # in: $dest = $ds[$key] using `in`
  ((asm ~{:bytecode @[(in 2 0 1)
                      (ret 2)]
          :arity 2})
    {:x :spot} :x)
  # =>
  :spot

  # jmp: pc += offset
  ((asm ~{:bytecode @[(jmp 3)
                      (ldi 0 0x8)
                      (ret 0)
                      (ldi 0 0x9)
                      (ret 0)]
          :arity 0}))
  # =>
  9

  # jpmif: if $cond pc += offset else pc++
  ((asm ~{:bytecode @[(jmpif 0 2)
                      (ret 1)
                      (ret 2)]
          :arity 3})
    true :ant :bee)
  # =>
  :bee

  # jmpni: if $cond == nil pc += offset else pc++
  ((asm ~{:bytecode @[(jmpni 0 2)
                      (ret 1)
                      (ret 2)]
          :arity 3})
    true :ant :bee)
  # =>
  :ant

  # jmpnn: if $cond != nil pc += offset else pc++
  ((asm ~{:bytecode @[(jmpnn 0 2)
                      (ret 1)
                      (ret 2)]
          :arity 3})
    true :ant :bee)
  # =>
  :bee

  # jmpno: if $cond pc++ else pc += offset
  ((asm ~{:bytecode @[(jmpno 0 2)
                      (ret 1)
                      (ret 2)]
          :arity 3})
    true :ant :bee)
  # =>
  :ant

  # ldc: $dest = constants[index]
  ((asm ~{:constants [:grin]
          :bytecode @[(ldc 0 0)
                      (ret 0)]
          :arity 0}))
  # =>
  :grin

  # ldf: $dest = false
  ((asm ~{:bytecode @[(ldf 0)
                      (ret 0)]
          :arity 0}))
  # =>
  false

  # ldi: $dest = integer
  ((asm ~{:bytecode @[(ldi 0 0x100)
                      (ret 0)]
          :arity 0}))
  # =>
  256

  # ldn: $dest = nil
  ((asm ~{:bytecode @[(ldn 0)
                      (ret 0)]
          :arity 0}))
  # =>
  nil

  # factorial with accumulator
  # lds: $dest = current closure (self)
  ((asm ~{:bytecode @[(ltim 2 0 0x2)
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

  # ldt: $dest = true
  ((asm ~{:bytecode @[(ldt 0)
                      (ret 0)]
          :arity 0}))
  # =>
  true

  # ldu: $dest = envs[env][index]
  ((asm '{:arity 1
          :bytecode @[(clo 1 0)             # $1 = defs[0]
                      (ldi 2 0x8)           # $2 = 8
                      (push 2)              # push $2 to args
                      (call 2 1)            # $2 = ($1 $2) == (defs[0] $2)
                      (ret 2)]              # return $2
          :defs @[{:arity 1
                   :bytecode @[(ldu 1 0 0)  # $1 = $0 from parent?
                               (add 2 1 0)  # $2 = $1 + $0
                               (ret 2)]     # return $2
                   :environments @[-1]}]})  # (ldu _ 0 _) refers to -1
    3)
  # =>
  11

  # len: $dest = length($ds)
  ((asm ~{:bytecode @[(len 0 0)
                      (ret 0)]
          :arity 1})
    [:ant :bee :cat])
  # =>
  3

  # lt: $dest = $lhs < $rhs
  ((asm ~{:bytecode @[(lt 0 0 1)
                      (ret 0)]
          :arity 2})
    math/-inf math/inf)
  # =>
  true

  # lte: $dest = $lhs <= $rhs
  ((asm ~{:bytecode @[(lte 0 0 1)
                      (ret 0)]
          :arity 2})
    0 1)
  # =>
  true

  # ltim: $dest = $lhs < im
  ((asm ~{:bytecode @[(ltim 0 0 0x1)
                      (ret 0)]
          :arity 1})
    0)
  # =>
  true

  # mkarr: $dest = call(array, args)
  ((asm ~{:bytecode @[(push3 0 1 2)
                      (mkarr 0)
                      (ret 0)]
          :arity 3})
    :elephant :fox :giraffe)
  # =>
  @[:elephant :fox :giraffe]

  # mkbtp: $dest = call(tuple/brackets, args)
  ((asm ~{:bytecode @[(push2 0 1)
                      (mkbtp 0)
                      (ret 0)]
          :arity 2})
    [] {})
  # =>
  '[() {}]

  # mkbuf: $dest = call(buffer, args)
  ((asm ~{:bytecode @[(push2 0 1)
                      (mkbuf 0)
                      (ret 0)]
          :arity 2})
    :hi " there")
  # =>
  @"hi there"

  # mkstr: $dest = call(string, args)
  ((asm ~{:bytecode @[(push2 0 1)
                      (mkstr 0)
                      (ret 0)]
          :arity 2})
    @"gday, m" 8)
  # =>
  "gday, m8"

  # mkstu: $dest = call(struct, args)
  ((asm ~{:bytecode @[(push3 0 1 2)
                      (push3 3 4 5)
                      (mkstu 0)
                      (ret 0)]
          :arity 6})
    :x 10 :y 20 :z 80)
  # =>
  {:x 10 :y 20 :z 80}

  # mktab: $dest = call(table, args)
  ((asm ~{:bytecode @[(push2 0 1)
                      (mktab 0)
                      (ret 0)]
          :arity 2})
    :breathe :slowly)
  # =>
  @{:breathe :slowly}

  # mktup: $dest = call(tuple, args)
  ((asm ~{:bytecode @[(push3 0 1 2)
                      (mktup 0)
                      (ret 0)]
          :arity 3})
    '+ 1 1)
  # =>
  '(+ 1 1)

  # mod: $dest = $lhs mod $rhs
  ((asm ~{:bytecode @[(mod 0 0 1)
                      (ret 0)]
          :arity 2})
    -3 2)
  # =>
  1

  # movf: $dest = $src
  ((asm ~{:bytecode @[(movf 0 1)  # (movf src dest)
                      (ret 1)]
          :arity 1})
    :echo)
  # =>
  :echo

  # movn: $dest = $src
  ((asm ~{:bytecode @[(movn 1 0)  # (movn dest src)
                      (ret 1)]
          :arity 1})
    :again)
  # =>
  :again

  # mul: $dest = $lhs * $rhs
  ((asm ~{:bytecode @[(mul 2 0 1)
                      (ret 2)]
          :arity 2})
    2 3)
  # =>
  6

  # mulim: $dest = $lhs * im
  ((asm ~{:bytecode @[(mulim 1 0 0x8)
                      (ret 1)]
          :arity 1})
    11)
  # =>
  88

  # neq: dest = $lhs != $rhs
  ((asm ~{:bytecode @[(neq 2 0 1)
                      (ret 2)]
          :arity 2})
    0 -0)
  # =>
  false

  # neqim: $dest = $lhs != im
  ((asm ~{:bytecode @[(neqim 2 0 0x23)
                      (ret 2)]
          :arity 1})
    22)
  # =>
  true

  # next: $dest = next($ds, $key)
  ((asm ~{:bytecode @[(next 2 0 1)
                      (ret 2)]
          :arity 2})
    [:a :b :c] 1)
  # =>
  2

  # noop: does nothing
  ((asm ~{:bytecode @[(noop)
                      (noop)
                      (noop)
                      (noop)
                      (noop)
                      (noop)
                      (noop)
                      (noop)
                      (ret 0)]
          :arity 1})
    math/inf)
  # =>
  math/inf

  # prop: propagate (re-raise) a signal that has been caught
  (do
    (def fib (coro :a))
    (resume fib)
    ((asm ~{:bytecode @[(prop 2 0 1)  # (prop dest val fiber)
                        (ldi 0 0x9)   # never reached
                        (ret 0)]
            :arity 2})
      "skip!" fib))
  # =>
  "skip!"

  # put: $ds[$key] = $val
  ((asm ~{:bytecode @[(put 0 1 2)  # (put ds key val)
                      (ret 0)]
          :arity 3})
    @{} :a 1)
  # =>
  @{:a 1}

  # puti: $ds[index] = $val
  ((asm ~{:bytecode @[(puti 0 1 0x0)  # (puti ds val index)
                      (ret 0)]
          :arity 2})
    @[] :smile)
  # =>
  @[:smile]

  # rem: $dest = $lhs % $rhs
  ((asm ~{:bytecode @[(rem 2 0 1)
                      (ret 2)]
          :arity 2})
    -3 2)
  # =>
  -1

  # res: $dest = resume $fiber with $val
  ((asm ~{:bytecode @[(res 2 0 1)
                      (ret 2)]
          :arity 2})
    (fiber/new (fn [x] (* x 8)))
    9)
  # =>
  72

  # ret: return $val
  ((asm ~{:bytecode @[(ret 0)]
          :arity 1})
    :love)
  # =>
  :love

  # retn: return nil
  ((asm ~{:bytecode @[(retn)]
          :arity 0}))
  # =>
  nil

  # setu: envs[env][index] = $val
  ((asm '{:arity 0
          :bytecode @[(clo 0 0)                 # define the closure
                      (ldi 1 0x8)               # prepare $1 for closure
                      (call 2 0)                # calling for side-effect
                      (ret 1)]                  # returned modified value
          :defs @[{:arity 0
                   :bytecode @[(ldu 0 0 1)      # $0 = parent's $1
                               (addim 0 0 0x1)  # increment $0
                               (setu 0 0 1)     # parent's $1 = $0
                               (retn)]          # caller ignores this
                   :environments @[-1]}]}))
  # =>
  (+ 0x8 0x1)

  # enum JanetSignal, JANET_SIGNAL_ERROR is 1
  # sig: $dest = emit $value as sigtype
  (try
    ((asm ~{:bytecode @[(sig 2 0 0x1)  # (sig dest value sigtype)
                        (ldi 1 0xff)   # never reached
                        (ret 1)]
            :arity 1})
      :wocky)
    ([e]
      (string "jabber" e)))
  # =>
  "jabberwocky"

  # sl: $dest = $lhs << $rhs
  ((asm ~{:bytecode @[(sl 2 0 1)
                      (ret 2)]
          :arity 2})
    2r10 3)
  # =>
  16

  # slim: $dest = $lhs << shamt
  ((asm ~{:bytecode @[(slim 1 0 0x3)
                      (ret 1)]
          :arity 1})
    2r10)
  # =>
  16

  # sr: $dest = $lhs >> $rhs
  ((asm ~{:bytecode @[(sr 2 0 1)
                      (ret 2)]
          :arity 2})
    -2r101 2)
  # =>
  -2

  # srim: $dest = $lhs >> shamt
  ((asm ~{:bytecode @[(srim 1 0 0x2)
                      (ret 1)]
          :arity 1})
    -2r101)
  # =>
  -2

  # sru: $dest = $lhs >>> $rhs
  ((asm ~{:bytecode @[(sru 2 0 1)
                      (ret 2)]
          :arity 2})
    2r1100 3)
  # =>
  1

  # sruim: $dest = $lhs >>> shamt
  ((asm ~{:bytecode @[(sruim 1 0 0x3)
                      (ret 1)]
          :arity 1})
    2r1100)
  # =>
  1

  # sub: $dest = $lhs - $rhs
  ((asm ~{:bytecode @[(sub 2 0 1)
                      (ret 2)]
          :arity 2})
    0 1)
  # =>
  -1

  # tcall: return call($callee, args)
  ((asm ~{:bytecode @[(tcall 0)]
          :arity 1})
    +)
  # =>
  0

  # enum JanetType, JANET_KEYWORD is 6, 2 ** 6 == 64
  # tchck: assert $slot matches types
  ((asm ~{:bytecode @[(tchck 0 64)
                      (ret 0)]
          :arity 1})
    :hello)
  # =>
  :hello

  )
