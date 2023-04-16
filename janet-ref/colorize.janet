(defn colorize
  [src &opt lang]
  (default lang "janet")
  (cond
    (= "rougify" (dyn :jref-colorizer))
    (let [p
          (try
            (os/spawn ["rougify"
                       "highlight" "--lexer" lang]
                      :px {:in :pipe :out :pipe})
            ([e]
              # XXX
              (eprintf "os/spawn failed, not coloring: %s" e)
              (break src)))]
      (:write (p :in) src)
      (:close (p :in))
      #
      (def res
        (:read (p :out) :all))
      (os/proc-kill p)
      res)
    #
    (= "pygmentize" (dyn :jref-colorizer))
    (let [p
          (try
            (os/spawn ["pygmentize"
                       "-P" (string "style=" (dyn :jref-colorizer-style))
                       "-l" (if (= "janet" lang)
                              "clojure"
                              lang)]
                      :px {:in :pipe :out :pipe})
            ([e]
              # XXX
              (eprintf "os/spawn failed, not coloring: %s" e)
              (break src)))]
      (:write (p :in) src)
      (:close (p :in))
      #
      (def res
        (:read (p :out) :all))
      (:wait p)
      res)
    #
    src))
