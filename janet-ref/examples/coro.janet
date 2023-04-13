(comment

  (do
    (def fib
      (coro
        (for i 0 3
          (yield i))))
    (resume fib)
    [(resume fib) (resume fib)])
  # =>
  [1 2]

  (do
    (var j 0)
    (def fib
      (coro
        (for i 1 5
          (yield (+ j i)))))
    [(resume fib)
     (set j 6)
     (resume fib) (resume fib)])
  # =>
  [1 6 8 9]

  (do
    (def fib-1
      (coro
        (yield :a)))
    (def fib-2
      (coro
        (yield fib-1)))
    (->> fib-2
         resume
         resume))
  # =>
  :a

  (do
    (var f1 nil)
    (var f2 nil)
    (set f1
      (coro
        (yield :a)
        (yield (resume f2))))
    (set f2
      (coro
        (yield :b)
        (yield (resume f1))))
    [(resume f1) (resume f1)])
  # =>
  [:a :b]

  (do
    (def to-f1 @[:your :to :be])
    (def to-f2 @[nil :drink :sure])
    (def to-f3 @[])
    (def f1
      (coro
        (forever
          (def msg (array/pop to-f1))
          (array/push to-f3 msg)
          (yield true))))
    (def f2
      (coro
        (forever
          (def msg (array/pop to-f2))
          (array/push to-f3 msg)
          (yield true))))
    (resume f1)
    (resume f2)
    (resume f1)
    (resume f2)
    (resume f1)
    (resume f2)
    to-f3)
  # =>
  @[:be :sure :to :drink :your nil]

  )
