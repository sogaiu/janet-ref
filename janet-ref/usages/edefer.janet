(comment

  (do
    (var state :untouched)
    (edefer (set state :altered)
      (for i 0 2
        (inc i)))
    state)
  # =>
  :untouched

  (do
    (var box nil)
    (try
      (edefer (set box :errored)
        (for i 0 3
          (when (pos? i)
            (error "must have goofed up somewhere..."))))
      ([e]
        box)))
  # =>
  :errored

  )
