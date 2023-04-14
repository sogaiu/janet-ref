(import ../jandent/indent)

(defn print-nicely
  [expr-str]
  (let [buf (indent/format expr-str)]
    (each line (string/split "\n" buf)
      (print line))))

(defn print-separator
  []
  (print (string/repeat "#" (dyn :jref-width))))

