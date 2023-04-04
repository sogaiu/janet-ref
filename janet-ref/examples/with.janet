(comment

  (do
    (def closed-file
      (with [f (file/temp)]
        (file/write f "a")))
    (->> (try
           (file/read closed-file :all)
           ([e]
             e))
         (string/find "file is closed")
         truthy?))
  # =>
  true

  (do
    (def source @[:a :b :c])
    (with [arr
           source
           array/clear]
      (array/push arr :x))
    (empty? source))
  # =>
  true

  )
