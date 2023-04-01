(import ../highlight/highlight :as hl)
(import ../jandent/indent)

(defn print-nicely
  [expr-str]
  (let [buf (hl/colorize (indent/format expr-str))]
    (each line (string/split "\n" buf)
      (print line))))

(defn print-separator
  []
  ((dyn :jref-hl-prin) (string/repeat "#" (dyn :jref-width))
                       (dyn :jref-separator-color)))

