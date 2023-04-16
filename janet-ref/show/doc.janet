(defn doc
  [content]
  (def m-lines @[])
  (def lines
    (string/split "\n" content))
  (when (empty? (array/peek lines))
    (array/pop lines))
  (each line lines
    (array/push m-lines
                (->> line
                     (peg/match ~(sequence "# "
                                           (capture (to -1))))
                     first)))
  #
  m-lines)

# assumes usage file for special form has certain structure
(defn massage-lines-for-special
  [lines]
  (def m-lines @[])
  (var i 0)
  (while (< i (length lines))
    (def cur-line (get lines i))
    # stop at first (comment ...) form
    (if (peg/match ~(sequence "(comment")
                     cur-line)
      (break)
      (if (string/has-prefix? "# " cur-line)
        (array/push m-lines (string/slice cur-line 2))
        (array/push m-lines cur-line)))
    (++ i))
  #
  m-lines)

(defn special-form-doc
  [content]
  (def lines
    (string/split "\n" content))
  #
  (massage-lines-for-special lines))

(defn massage-lines
  [lines]
  # figure out where first non-blank line is
  (var i 0)
  (while (< i (length lines))
    (if (not (empty? (get lines i)))
      (break)
      (++ i)))
  # i might equal (length lines) if data is not sound
  (assert (not= i (length lines))
          (string/format "Something seems odd about lines: %p"
                         lines))
  # figure out where last non-blank line is
  (var j (dec (length lines)))
  (while (<= 0 j)
    (if (not (empty? (get lines j)))
      (break)
      (-- j)))
  # find indentation of first non-blank line
  (var indent 0)
  (for k 0 (length lines)
    (let [matches
          (peg/match ~(capture :s+) (get lines k))]
      (when matches
        (set indent (length (first matches)))
        (break))))
  #
  (def m-lines @[])
  (each line (array/slice lines i (inc j))
    (if (>= (length line) indent)
      (array/push m-lines (string/slice line indent))
      (array/push m-lines line)))
  #
  m-lines)

(defn thing-doc
  [thing]
  (def buf @"")
  (cond
    ((curenv) (symbol thing))
    (with-dyns [*out* buf]
      (eval-string (string/format `(doc %s)` thing)))
    #
    (with-dyns [*out* buf]
      (eval-string (string/format `(doc "%s")` thing))))
  #
  (def lines
    (string/split "\n" buf))
  #
  (massage-lines lines))

