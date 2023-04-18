(comment

  (do
    (def buf @"")
    (with-dyns [*out* buf]
      (print "greetings"))
    buf)
  # =>
  @"greetings\n"

  (do
    (def buf @"")
    (with-dyns [*out* buf]
      (prin "not quote done"))
    buf)
  # =>
  @"not quote done"

  (do
    (def buf @"")
    (with-dyns [*out* buf]
      (printf "...and then %s" `another`))
    buf)
  # =>
  @"...and then another\n"

  (do
    (def buf @"")
    (with-dyns [*out* buf]
      (prinf "hello %s" `dave`))
    buf)
  # =>
  @"hello dave"

  )
