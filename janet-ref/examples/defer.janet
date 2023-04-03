(comment

  (do
    (var state nil)
    (defer (set state :altered)
      (for i 0 2
        (inc i)))
    state)
  # =>
  :altered

  (do
    (var box nil)
    (try
      (defer (set box :hope)
        (for i 0 3
          (when (pos? i)
            (error "must have goofed up somewhere..."))))
      ([e]
        box)))
  # =>
  :hope

  )
