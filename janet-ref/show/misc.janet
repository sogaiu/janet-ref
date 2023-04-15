(import ../jandent/indent)

(defn colorize
  [src]
  (cond
    (= "rougify" (dyn :jref-colorizer))
    (let [p
          (os/spawn ["rougify"
                     "highlight" "--lexer" "janet"]
                    :px {:in :pipe :out :pipe})]
      (:write (p :in) src)
      (:close (p :in))
      #
      (:read (p :out) :all))
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

