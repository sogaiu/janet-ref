```
special form

`(set l-value r-value)`

Update the value of the var `l-value` with the new `r-value`.

The `set` special form will then evaluate to `r-value`.

The `r-value` can be any expression, and the `l-value` should be a
bound var or a pair of a data structure and key. This allows `set` to
behave like `setf` or `setq` in Common Lisp.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  (do
    (var x 1)
    (set x 2))
  # =>
  2

  (do
    (set (@{:a 1} :a)
         3))
  # =>
  3

  (do
    (def tbl @{:x 8})
    (set (tbl :x)
         9)
    tbl)
  # =>
  @{:x 9}

  (do
    (def arr @[0 1])
    (set (arr 1)
         3)
    arr)
  # =>
  @[0 3]

  (do
    (def buf @"hello")
    (set (buf 1)
         (chr "a"))
    buf)
  # =>
  @"hallo"

  )
