(import ../highlight/highlight :as hl)

# XXX: not sure if this quoting will work on windows...
(defn escape
  [a-str]
  (string "\""
          a-str
          "\""))

(defn all-things
  [things]
  # print all things
  (each thing (sort things)
    # XXX: need to add a lot here or use some kind of
    #      pattern matching?
    # XXX: anything platform-specific?
    (if (get {"*" true
              "->" true
              ">" true
              "<-" true
              "|" true}
             thing)
      (print (escape thing))
      (print thing))))

(defn doc
  [content]
  (def lines
    (string/split "\n" content))
  (when (empty? (array/peek lines))
    (array/pop lines))
  (each line lines
    (->> line
         (peg/match ~(sequence "# "
                               (capture (to -1))))
         first
         print)))

(defn massage-lines!
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
  [(array/slice lines i (inc j)) indent])

(defn thing-doc
  [thing]
  (def doc-arg
    (cond
      ((curenv) (symbol thing))
      thing
      # XXX: make a table for special forms somewhere?
      (get {"def" true
            "var" true
            "fn" true
            "quote" true
            "if" true
            "splice" true
            "while" true
            "break" true
            "set" true
            "quasiquote" true
            "unquote" true
            "upscope" true}
           thing)
      thing
      #
      (string/format `"%s"` thing)))
  (def buf @"")
  # XXX: for things that are in curenv, could just pull
  #      out the associated value of :doc from result
  #      of ((curenv) (symbol thing))
  (with-dyns [*out* buf]
    (eval-string (string/format "(doc %s)" doc-arg)))
  (def lines
    (string/split "\n" buf))
  (def [m-lines indent]
    (massage-lines! lines))
  #
  (each line m-lines
    (if (>= (length line) indent)
      (print (string/slice line indent))
      (print line))))

