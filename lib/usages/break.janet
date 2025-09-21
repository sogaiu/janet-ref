```
special form

`(break value?)`

Break from a `while` loop or return early from a function.

The `break` special form can only break from the inner-most loop.

Since a `while` loop always returns `nil`, the optional value
parameter has no effect when used in a `while` loop, but when
returning from a function, the value parameter is the function's
return value.

The `break` special form is most useful as a low level construct for
macros. You should try to avoid using it in handwritten code, although
it can be very useful for handling early exit conditions without
requiring deeply indented code (try the `cond` macro first, though).

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  (while true
    (break))
  # =>
  nil

  (do
    (def arr @[])
    (for i 0 2
      (array/push arr i)
      (when (pos? i)
        (break)))
    arr)
  # =>
  @[0 1]

  (do
    (var tot 0)
    (each i [-1 0 1]
      (+= tot i)
      (when (zero? i)
        (break)))
    tot)
  # =>
  -1

  (do
    (var r nil)
    (for i 0 2
      (for j 0 2
        (when (and (pos? i) (pos? j))
          (break)))
      (set r i))
    r)
  # =>
  1

  (do
    (defn a-fn
      []
      (when (> (math/random) 0.5)
        (break 1))
      (when (> (math/random) 0.5)
        (break 2))
      3)
    (get {1 true 2 true 3 true}
         (a-fn)))
  # =>
  true

  )
