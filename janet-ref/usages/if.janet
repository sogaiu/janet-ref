```
special form

`(if condition when-true when-false?)`

Introduce a branching construct.

The first form is the condition, the second form is the form to
evaluate when the condition is `true`, and the optional third form
is the form to evaluate when the condition is `false`. If no third
form is provided it defaults to `nil`.

The `if` special form will not evaluate the `when-true` or
`when-false` forms unless it needs to - it is a lazy form, which is
why it cannot be a function.

The condition is considered `false` only if it evaluates to `nil` or
`false` - all other values are considered `true`.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

(comment

  (if true
    1
    2)
  # =>
  1

  (if false
    :green
    :blue)
  # =>
  :blue

  (if (= 1 1) :clever)
  # =>
  :clever

  (if (= 0 1)
    :anything-is-possible
    :nothing-to-see-here)
  # =>
  :nothing-to-see-here

  )


