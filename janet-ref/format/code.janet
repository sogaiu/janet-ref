(import ../parse/location :as loc)

# keys are numbers that represent which element of a call (involving
# the symbol associatated with the name) is the first one to have a
# newline after it.  all subsequent things have newlines after them
# for simplicity.
#
# e.g. "do" is associated with 0 because in a "do" form:
#
#      (do
#        form-1
#        form-2
#        ...
#        form-n)
#
#      the 0-th item ("do") is the first element of the call (tuple)
#      with a newline after it, and all subsequent elements have
#      newlines after them.
(def nl-things
  {0 ["comment" "cond" "coro"
      "do"
      "forever"
      "protect"
      "try"
      "upscope"]
   1 ["accumulate" "and" "assert"
      "case" "count"
      "def" "defdyn" "defer" "defn" "drop-until" "drop-while"
      "edefer"
      "filter" "find" "find-index" "fn"
      "generate"
      "if" "if-let" "if-not" "if-with"
      "keep"
      "label" "let" "loop"
      "map" "mapcat"
      "nan?"
      "or"
      "prompt"
      "reduce" "repeat"
      "seq" "set"
      "tabseq" "take-until" "take-while"
      "unless"
      "var"
      "when" "when-let" "when-with" "while" "with" "with-syms"]
   2 ["each" "eachk" "eachp"]
   3 ["for" "forv"]
   # means don't use newlines -- here for book-keeping
   -1 ["+="
       "array/concat" "asm"
       "break"
       "chr" "comp" "compare" "complement"
       "dec" "default" "drop"
       # XXX
       "errorf" "extreme"
       "fiber?" "first"
       "identity" "inc" "index-of" "interpose"
       # XXX
       "juxt" "juxt*"
       "last"
       # XXX
       #"mapcat"
       "max" "max-of" "mean" "min" "min-of"
       "number?"
       "product"
       "quasiquote" "quote"
       "range" "return"
       "sort" "sort-by" "sorted" "splice" "sum"
       "take" "toggle"
       "unquote"]})

(def nl-tbl
  (let [tbl @{}]
    (eachp [num names] nl-things
      (when (>= num 0)
        (each name names
          (put tbl
               name (fn [i] (>= i num))))))
    tbl))

(defn fmt
  [src]
  (def buf @"")
  (def an-ast (loc/par src))
  (def indt-stack @[""])
  (var cur-col 0)
  #
  (defn fmt*
    [an-ast buf]
    (def the-type (first an-ast))
    (cond
      (= :code the-type)
      (let [items (filter |(and (not= :whitespace (first $))
                                (not= :comment (first $)))
                          (drop 2 an-ast))]
        (each elt items
          (fmt* elt buf)
          (buffer/push-string buf "\n\n"))
        (when (string/has-suffix? "\n\n" buf)
          (buffer/popn buf 2)))
      #
      (= :tuple the-type)
      (let [open-delim "("
            close-delim ")"
            items (filter |(and (not= :whitespace (first $))
                                (not= :comment (first $)))
                          (drop 2 an-ast))
            has-dict? (find |(or (= :struct (first $))
                                 (= :table (first $)))
                            items)]
        (+= cur-col (length open-delim))
        (buffer/push-string buf open-delim)
        (array/push indt-stack
                    (string/repeat " " cur-col))
        # different strategy if any dictionaries are elements
        (if has-dict?
          (do
            (each elt items
              (fmt* elt buf)
              #
              (set cur-col (length (array/peek indt-stack)))
              (buffer/push-string buf "\n")
              (buffer/push-string buf (array/peek indt-stack)))
            (when (string/has-suffix? (string "\n" (array/peek indt-stack))
                                      buf)
              (buffer/popn buf (+ 1 (length (array/peek indt-stack))))))
          (do
            (when (pos? (length items))
              (def [_ _ name-of-first]
                (first items))
              (def nl-fn
                (get nl-tbl name-of-first
                     (fn [i] false)))
              (for i 0 (length items)
                (fmt* (get items i) buf)
                (if (nl-fn i)
                  (buffer/push-string buf "\n")
                  (buffer/push-string buf " "))
                # XXX: is this right?
                (set cur-col (length (array/peek indt-stack))))
              (when (or (string/has-suffix? "\n" buf)
                        (string/has-suffix? " " buf))
                (buffer/popn buf 1)))))
          # XXX: is this correct?
        (set cur-col (length (array/peek indt-stack)))
        (array/pop indt-stack)
        (buffer/push-string buf close-delim))
      #
      (get {:unreadable true
            #
            :whitespace true
            :comment true
            #
            :buffer true
            :constant true
            :keyword true
            :long-buffer true
            :long-string true
            :number true
            :string true
            :symbol true}
           the-type)
      (let [item (in an-ast 2)]
        (+= cur-col (length item))
        (buffer/push-string buf item))
      #
      (get {:array true
            :bracket-array true
            :bracket-tuple true}
           the-type)
      (let [[open-delim close-delim]
            (case the-type
              :array ["@(" ")"]
              :bracket-array ["@[" "]"]
              :bracket-tuple ["[" "]"])
            items (filter |(and (not= :whitespace (first $))
                                (not= :comment (first $)))
                          (drop 2 an-ast))
            has-dict? (find |(or (= :struct (first $))
                                 (= :table (first $)))
                            items)]
        (+= cur-col (length open-delim))
        (buffer/push-string buf open-delim)
        (array/push indt-stack
                    (string/repeat " " cur-col))
        # different strategy if any dictionaries are elements
        (if has-dict?
          (do
            (each elt items
              (fmt* elt buf)
              #
              (set cur-col (length (array/peek indt-stack)))
              (buffer/push-string buf "\n")
              (buffer/push-string buf (array/peek indt-stack)))
            (when (string/has-suffix? (string "\n" (array/peek indt-stack))
                                      buf)
              (buffer/popn buf (+ 1 (length (array/peek indt-stack))))))
          (do
            (each elt items
              (fmt* elt buf)
              #
              (set cur-col (length (array/peek indt-stack)))
              (buffer/push-string buf " "))
            (when (string/has-suffix? " " buf)
              (buffer/popn buf 1))))
        # XXX: is this correct?
        (set cur-col (length (array/peek indt-stack)))
        (array/pop indt-stack)
        (buffer/push-string buf close-delim))
      #
      (get {:struct true
            :table true}
           the-type)
      (let [[open-delim close-delim]
            (case the-type
              :struct ["{" "}"]
              :table ["@{" "}"])
            items (filter |(and (not= :whitespace (first $))
                                (not= :comment (first $)))
                          (drop 2 an-ast))]
        (+= cur-col (length open-delim))
        (buffer/push-string buf open-delim)
        (array/push indt-stack
                    (string/repeat " " cur-col))
        # format elements
        (for i 0 (/ (length items) 2)
          (def idx (* i 2))
          (fmt* (get items idx) buf)
          #
          (+= cur-col 1)
          (buffer/push-string buf " ")
          #
          (fmt* (get items (inc idx)) buf)
          #
          (set cur-col (length (array/peek indt-stack)))
          (buffer/push-string buf "\n")
          (buffer/push-string buf (array/peek indt-stack)))
        # XXX: is 0 correct, here?
        (set cur-col 0)
        (when (string/has-suffix? (string "\n" (array/peek indt-stack))
                                  buf)
          (buffer/popn buf (+ 1 (length (array/peek indt-stack)))))
        (array/pop indt-stack)
        (buffer/push-string buf close-delim))
      # XXX: janet itself won't print things with any of the following?
      (get {:fn true
            :quasiquote true
            :quote true
            :splice true
            :unquote true}
           the-type)
      (let [sigil
            (case the-type
              :fn "|"
              :quasiquote "~"
              :quote "'"
              :splice ";"
              :unquote ",")
            # XXX: should only be one thing left?
            items (filter |(and (not= :whitespace (first $))
                                (not= :comment (first $)))
                          (drop 2 an-ast))]
        (+= cur-col (length sigil))
        (buffer/push-string buf sigil)
        (each elt items
          (fmt* elt buf)))
      #
      (errorf "Unexpected type: %s" the-type)
      )
    buf)
  #
  (fmt* an-ast buf))

(comment

  (def src-0
    ``
    (if true (do (print)))
    ``)

  (fmt src-0)
  # =>
  @``
   (if true
   (do
   (print)))
   ``

  (def src-1
    ``
    (def a 1)
    ``)

  (fmt src-1)
  # =>
  @``
   (def a
   1)
   ``

  (def src-2
    ``
    (var b 2)
    ``)

  (fmt src-2)
  # =>
  @``
   (var b
   2)
   ``

  (def src-3
    ``
    (while true (++ i) i)
    ``)

  (fmt src-3)
  # =>
  @``
   (while true
   (++ i)
   i)
   ``

  (def src-4
    ``
    (let [x 1] (+ x 2))
    ``)

  (fmt src-4)
  # =>
  @``
   (let [x 1]
   (+ x 2))
   ``

  (def src-5
    ``
    (if true :smile :jump)
    ``)

  (fmt src-5)
  # =>
  @``
   (if true
   :smile
   :jump)
   ``

  (def src-6
    ``
    (fn [x] (+ x 1))
    ``)

  (fmt src-6)
  # =>
  @``
   (fn [x]
   (+ x 1))
   ``

  (def src-7
    ``
    (def a 1) (while true (break))
    ``)

  (fmt src-7)
  # =>
  @``
   (def a
   1)

   (while true
   (break))
   ``

  )
