```
special form

`(var name meta... value)`

`var` binds a value to a symbol.

The symbol can be substituted for the value in subsequent expressions
for the same result.

A binding made by `var` can be updated using `set`.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  (do
    (var a 1)
    a)
  # =>
  1

  (do
    (var a 1)
    (var a 2)
    a)
  # =>
  2

  (do
    (var a 1)
    (set a 3)
    a)
  # =>
  3

  (do
    (var a 1)
    (do
      (var a 2))
    a)
  # =>
  1

  (do
    (var [a b]
      [1 2])
    a)
  # =>
  1

  (do
    (var [x y & rest]
      [1 2 3 8 9])
    rest)
  # =>
  '(3 8 9)

  (do
    (var {:a a
          :b b}
      (table :a 1
             :b 2))
    b)
  # =>
  2

  )
