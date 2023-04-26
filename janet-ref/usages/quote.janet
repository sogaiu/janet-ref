```
special form

`(quote x)`

Evaluates to the literal value of the first argument.

The argument is not compiled and is simply used as a constant value in
the compiled code.

Preceding a form with a single quote is shorthand for `(quote form)`.
Thus `'form` and `(quote form)` are equivalent.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  (quote x)
  # =>
  'x

  'x
  # =>
  'x

  '(:a :b :c)
  # =>
  '(:a :b :c)

  (quote (+ 1 1))
  # =>
  '(+ 1 1)

  )
