(comment

  (try
    (errorf "%s" "captured")
    ([e]
      e))
  # =>
  "captured"

  )
