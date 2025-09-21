```
special form

`(def name meta... value)`

`def` binds a value to a symbol.

The symbol can be substituted for the value in subsequent expressions
for the same result.

A binding made by `def` is a constant and cannot be updated.  A symbol
can be redefined to a new value, but previous uses of the binding will
refer to the previous value of the binding.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  (do
    (def a 1)
    a)
  # =>
  1

  (do
    (def a 1)
    (def a 2)
    a)
  # =>
  2

  (do
    (def a 1)
    (do
      (def a 2))
    a)
  # =>
  1

  (do
    (def [a b]
      [1 2])
    a)
  # =>
  1

  (do
    (def [x y & rest]
      [1 2 3 8 9])
    rest)
  # =>
  '(3 8 9)

  (do
    (def {:a a
          :b b}
      (table :a 1
             :b 2))
    b)
  # =>
  2

  )
