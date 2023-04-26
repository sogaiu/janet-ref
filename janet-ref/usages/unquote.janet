```
special form

`(unquote x)`

Unquote a form within a `quasiquote`. Outside of a `quasiquote`,
`unquote` is invalid.

The shorthand for `(unquote x)` is `,x`.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  (do
    (def a 1)
    (quasiquote (unquote a)))
  # =>
  1

  (do
    (def b 2)
    ~,b)
  # =>
  2

  )
