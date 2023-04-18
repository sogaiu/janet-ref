(defn xform-with-process
  [a-str cmd-tup]
  (def p
    (try
      (os/spawn cmd-tup
                :px {:in :pipe :out :pipe})
      ([e]
        # XXX
        (eprintf "os/spawn failed, not coloring: %s" e)
        (break a-str))))
  #
  (ev/write (p :in) a-str)
  (ev/close (p :in))
  #
  (def buf @"")
  (try
    # XXX: this is async -- provide a timeout?
    (ev/read (p :out) :all buf)
    ([e]
      (eprintf "ev/read failed, not coloring: %s" e)
      (break a-str)))
  # in this case, following should wait as well
  (os/proc-close p)
  #
  buf)

(defn colorize
  [src &opt lang]
  (default lang "janet")
  (cond
    (= "bat" (dyn :jref-colorizer))
    (xform-with-process src
                        ["bat"
                         "--style=plain"
                         "--paging=never"
                         "--force-colorization"
                         "--theme" (dyn :jref-colorizer-style)
                         "-l" (if (= "janet" lang)
                                "clojure"
                                lang)])
    #
    (= "pygmentize" (dyn :jref-colorizer))
    (xform-with-process src
                        ["pygmentize"
                         "-P" (string "style=" (dyn :jref-colorizer-style))
                         "-l" (if (= "janet" lang)
                                "clojure"
                                lang)])
    #
    (= "rougify" (dyn :jref-colorizer))
    (xform-with-process src
                        ["rougify"
                         "highlight"
                         "--lexer" lang
                         "--theme" (dyn :jref-colorizer-style)])
    #
    src))

