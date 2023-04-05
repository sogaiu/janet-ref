(comment

  (each i [])
  # =>
  nil

  (do
    (def arr @[])
    (def tup [:a :b :c])
    (each elt tup
      (array/push arr elt))
    arr)
  # =>
  @[:a :b :c]

  (do
    (def tbl @{})
    (def tup [:a :b :c])
    (each elt tup
      (put tbl elt true))
    tbl)
  # =>
  @{:a true :b true :c true}

  (do
    (def buf @"")
    (def zoo [:ant :bee :cat])
    (each animal zoo
      (when (= animal :cat)
        (break))
      (buffer/push buf animal "!"))
    buf)
  # =>
  @"ant!bee!"

  )
