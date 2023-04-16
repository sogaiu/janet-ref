(comment

  (case (+ 1 2)
    1
    :nope
    #
    2
    :try-again
    #
    3
    :yay!)
  # =>
  :yay!

  (case :fun)
  # =>
  nil

  (case :odd-trivial
    :highlander)
  # =>
  :highlander

  (case :odd-for-real
    3.1415926535
    :approximate
    #
    2.71828
    :still-not-quite
    #
    0)
  # =>
  0

  )
