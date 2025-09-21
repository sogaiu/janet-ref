```
special form

`(splice x)`

The `splice` special form is an interesting form that allows an array
or tuple to be put into another form inline.

It only has an effect in two places - as an argument in a function
call or literal constructor, or as the argument to the `unquote` form.

Outside of these two settings, the `splice` special form simply
evaluates directly to its argument `x`.

The shorthand for `splice` is prefixing a form with a semicolon.  So
`(splice form)` is equivalent to `;form`.

The `splice` special form has no effect on the behavior of other
special forms, except as an argument to `unquote`.

In the context of a function call, `splice` will insert the contents
of `x` in the parameter list.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  (+ (splice [1 2 3]))
  # =>
  6

  (* ;[1 2 3])
  # =>
  6

  )
