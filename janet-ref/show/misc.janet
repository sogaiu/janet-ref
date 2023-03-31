(defn print-separator
  []
  ((dyn :jref-hl-prin) (string/repeat "#" (dyn :jref-width))
                       (dyn :jref-separator-color)))

