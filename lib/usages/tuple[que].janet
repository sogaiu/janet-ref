(comment

  (tuple? [:a :b])
  # =>
  true

  (tuple? '(:x :y :z))
  # =>
  true

  (tuple? (freeze @[:ant :bee]))
  # =>
  true

  (tuple? (drop 1 [-1 0 1]))
  # =>
  true

  (tuple? (drop-until even? [-1 1 3 8]))
  # =>
  true

  (tuple? (drop-while odd? [-1 1 3 8]))
  # =>
  true

  (tuple? (take 2 @[-2 -1 0]))
  # =>
  true

  (tuple? (take-until even? [-3 -1 0]))
  # =>
  true

  (tuple? (take-while odd? [-5 -3 -1 8]))
  # =>
  true

  (tuple? (protect (error :hey)))
  # =>
  true

  (tuple? (string/bytes "smile"))
  # =>
  true

  (tuple? (-> (disasm (fn [] :a))
              (get :bytecode)
              first))
  # =>
  true

  (tuple? @[])
  # =>
  false

  (tuple? @())
  # =>
  false

  )
