```
special form

`(quasiquote x)`

Similar to `(quote x)`, but allows for unquoting within `x`.

This makes `quasiquote` useful for writing macros, as a macro
definition often generates a lot of templated code with a few custom
values.

The shorthand for `quasiquote` is a leading tilde `~` before a form.
So `(quasiquote x)` is equivalent to `~x`.

Within that form, `(unquote x)` will evaluate and insert `x` into the
`unquote` form.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  ~x
  # =>
  'x

  (quasiquote x)
  # =>
  'x

  (do
    (def a 1)
    (quasiquote (unquote a)))
  # =>
  1

  ~{:main (sequence "a" "b")}
  # =>
  '{:main (sequence "a" "b")}

  (do
    (def a 1)
    ~{:main (choice "a" ,a)})
  # =>
  '{:main (choice "a" 1)}

  )
