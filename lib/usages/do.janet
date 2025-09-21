```
special form

`(do body...)`

Execute a series of forms for side effects and evaluates to the final
form.

Also introduces a new lexical scope without creating or calling a
function.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  (do)
  # =>
  nil

  (do
    true)
  # =>
  true

  (do
    (print "hi")
    (+ 1 1))
  # =>
  2

  (do
    (do
      :fun))
  # =>
  :fun

  (do
    (def a 1)
    a)
  # =>
  1

  (do
    (def a 1)
    (do
      (def a 2))
    a)
  # =>
  1

  )
