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


