(comment

  (do
    (defdyn *special-flag*
      "A special flag for ...")
    (setdyn *special-flag* (math/random))
    (= (dyn :special-flag)
       (dyn *special-flag*)))
  # =>
  true

  )
