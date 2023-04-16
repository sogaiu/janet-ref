(comment

  (try
    (assert (= true false))
    ([e]
      :caught))
  # =>
  :caught

  (try
    (assert (= true false)
            "Sorry, no contradictions allowed")
    ([e]
      :caught-2-arg-version))
  # =>
  :caught-2-arg-version

  (assert (= true true)
          "At least some level of consistency")
  # =>
  true

  )
