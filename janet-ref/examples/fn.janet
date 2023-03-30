(comment

  (function? (fn [] 1))
  # =>
  true

  ((fn [] 1))
  # =>
  1

  ((fn [x] x) ((fn [] 1)))
  # =>
  1

  (do
    (def a
      (fn [] 8))
    (a))
  # =>
  8

  (do
    (def a 9)

    (def b
      (fn [] a))

    (b))
  # =>
  9

  (do
    (def my-caller
      (fn [f]
        (f)))
    (my-caller (fn [] :fun)))
  # =>
  :fun

  )

(comment

  (do
    (var n 3)
    (var b nil)
    (def stack @[])

    (def a
      (fn []
        (if (pos? n)
          (do
            (array/push stack (keyword (string "a-" n)))
            (set n (dec n))
            (b))
          (array/push stack :a-done))))

    (set b
         (fn []
           (if (pos? n)
             (do
               (array/push stack (keyword (string "b-" n)))
               (set n (dec n))
               (a))
             (array/push stack :b-done))))

    (a)

    stack)
  # =>
  [:a-3 :b-2 :a-1 :b-done]

  )
