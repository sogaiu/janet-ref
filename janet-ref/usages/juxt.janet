(comment

  (function? (juxt inc dec))
  # =>
  true

  ((juxt inc dec zero?) 2)
  # =>
  [3 1 false]

  )
