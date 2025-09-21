(comment

  (fiber? (coro
            (for i 0 3
              (yield i))))
  # =>
  true

  (fiber? (ev/cancel (coro
                       (for i 0 2
                         (yield i)))
                     "fiber cancelled"))
  # =>
  true

  (fiber? (fiber/new (fn [] 1)))
  # =>
  true

  (fiber? (fiber-fn :yi
                    (yield :smile)))
  # =>
  true

  (fiber? (fiber/current))
  # =>
  true

  (try
    (error "oops")
    ([e f]
      (fiber? f)))
  # =>
  true

  )
