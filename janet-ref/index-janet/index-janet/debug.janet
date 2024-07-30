(defn deprintf
  [fmt & args]
  (when (dyn :ij-debug)
    (eprintf fmt ;args)))

(defn deprint
  [msg]
  (when (dyn :ij-debug)
    (eprint msg)))
