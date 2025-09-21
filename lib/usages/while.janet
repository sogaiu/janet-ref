```
special form

`(while condition body...)`

The `while` special form compiles to a C-like while loop.

The `body` of the form will be continuously evaluated until the
condition is `false` or `nil`.  Therefore, it is expected that the
`body` will contain some side effects or the loop will go on forever.

The `while` loop always evaluates to `nil`.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  (while true
    (break))
  # =>
  nil

  (do
    (var i 3)
    (while (pos? i)
      (-- i)))
  # =>
  nil

  )
