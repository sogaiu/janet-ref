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
  (def colorizer (dyn :jref-colorizer))
  (def colorizer-style (dyn :jref-colorizer-style))
  (def colorizer-filename
    (if-let [colorizer-filename (dyn :jref-colorizer-filename)]
      colorizer-filename
      (if (= :windows (os/which))
        (string colorizer ".exe")
        colorizer)))
  (cond
    (= "bat" colorizer)
    (xform-with-process src
                        [colorizer-filename
                         "--style=plain"
                         "--paging=never"
                         "--force-colorization"
                         "--theme" colorizer-style
                         "-l" (if (= "janet" lang)
                                "clojure"
                                lang)])
    #
    (= "pygmentize" colorizer)
    (xform-with-process src
                        [colorizer-filename
                         "-P" (string "style=" colorizer-style)
                         "-l" (if (= "janet" lang)
                                "clojure"
                                lang)])
    #
    (= "rougify" colorizer)
    (xform-with-process src
                        [colorizer-filename
                         "highlight"
                         "--lexer" lang
                         "--theme" colorizer-style])
    #
    src))

