(import ../jandent/indent)

(defn colorize
  [src]
  (cond
    (= "rougify" (dyn :jref-colorizer))
    (let [p
          (try
            (os/spawn ["rougify"
                       "highlight" "--lexer" "janet"]
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
    src))

(defn print-nicely
  [expr-str]
  (let [buf (indent/format expr-str)]
    (each line (string/split "\n" (colorize buf))
      (print line))))

(defn print-separator
  []
  (print (string/repeat "#" (dyn :jref-width))))

