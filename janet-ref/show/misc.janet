(import ../jandent/indent)
(import ../colorize :as col)

(defn print-nicely
  [expr-str]
  (let [buf (indent/format expr-str)
        lines (string/split "\n" (col/colorize buf))]
    (when (zero? (length (last lines)))
      (array/pop lines))
    (each line lines
      (print line))))

(defn print-nicely-mono
  [expr-str]
  (let [buf (indent/format expr-str)
        lines (string/split "\n" buf)]
    (when (zero? (length (last lines)))
      (array/pop lines))
    (each line lines
      (print line))))

(defn print-separator
  []
  (print (string/repeat "#" (dyn :jref-width))))

