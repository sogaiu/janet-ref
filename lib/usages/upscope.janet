```
special form

`(upscope & body)`

Similar to `do`, `upscope` evaluates a number of forms in sequence and
evaluates to the result of the last form.

However, `upscope` does not create a new lexical scope, which means
that bindings created inside it are visible in the scope where
`upscope` is declared. This is useful for writing macros that make
several `def` and `var` declarations at once.

In general, use this macro as a last resort. There are other, often
better ways to do this, including using destructuring.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  (do
    (def a 1)
    (upscope
      (def a 2))
    a)
  # =>
  2

  )
