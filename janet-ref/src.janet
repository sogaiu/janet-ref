(import ./parse/c :as c)
(import ./parse/etags :as etags)
(import ./parse/location :as loc)

(defn scan-back
  [a-str a-char start n-times]
  (var cnt n-times)
  (var idx start)
  (def target (get a-char 0))
  (while (and (not (zero? idx))
              (not (zero? cnt)))
    (when (= target
             (get a-str idx))
      (-- cnt))
    (-- idx))
  (if (zero? cnt)
    (inc idx)
    nil))

(comment

  (scan-back (string "hello\n"
                     "there\n"
                     "friend")
             "\n"
             16
             2)
  # =>
  5

  )

(defn dedent
  [src]
  (def m
    (peg/match ~(capture (any " ")) src))
  (if (nil? m)
    src
    (let [n-spaces (length (first m))
          lines (string/split "\n" src)]
      (string/join (map (fn [line]
                          (if (< n-spaces
                                 (length line))
                            (string/slice line n-spaces)
                            line))
                        lines)
                   "\n"))))

(comment

  (def src
    ``
        janet_quick_asm(env, JANET_FUN_BNOT,
                        "bnot", 1, 1, 1, 1, bnot_asm, sizeof(bnot_asm),
                        JDOC("(bnot x)\n\nReturns the ... of integer x."));
    ``)

  (dedent src)
  # =>
  ``
  janet_quick_asm(env, JANET_FUN_BNOT,
                  "bnot", 1, 1, 1, 1, bnot_asm, sizeof(bnot_asm),
                  JDOC("(bnot x)\n\nReturns the ... of integer x."));
  ``

  )

(defn print-c-location
  [id line full-path]
  (print "/* ")
  (print "   " id)
  (printf "   +%d %s" line full-path)
  (print "*/"))

# XXX: need tests for this?
(defn handle-c
  [id-name line position search-str full-path src]
  (def trimmed-search-str
    (string/trim search-str))
  (cond
    (string/has-prefix? "static" trimmed-search-str)
    (let [m (peg/match c/c-grammar src position)]
      (when (or (nil? m) (empty? m))
        (eprintf "Failed to find end of definition for %s in %s"
                 id-name full-path)
        (break nil))
      (def [_ col end-pos] (find |(= :curly (first $)) m))
      (assert (= col 1)
              (string/format "Unexpected col value: %d" col))
      (print (dedent (string/slice src position (inc end-pos))))
      (print)
      (print-c-location id-name line full-path)
      true)
    #
    (or (string/has-prefix? "JANET_CORE_DEF" trimmed-search-str)
        (string/has-prefix? "janet_def" trimmed-search-str)
        (string/has-prefix? "templatize_comparator" trimmed-search-str)
        (string/has-prefix? "templatize_varop" trimmed-search-str))
    (let [m (peg/match c/c-grammar src position)]
      (when (or (nil? m) (empty? m))
        (eprintf "Failed to find end of definition for %s in %s"
                 id-name full-path)
        (break nil))
      (def [_ col end-pos] (find |(= :semi-colon (first $)) m))
      (print (dedent (string/slice src position (inc end-pos))))
      (print)
      (print-c-location id-name line full-path)
      true)
    # some things from math.c
    (or (string/has-prefix? "JANET_DEFINE_MATHOP" trimmed-search-str)
        (string/has-prefix? "JANET_DEFINE_NAMED_MATHOP" trimmed-search-str)
        (string/has-prefix? "JANET_DEFINE_MATH2OP" trimmed-search-str))
    (let [m (peg/match c/c-grammar src position)]
      (when (or (nil? m) (empty? m))
        (eprintf "Failed to find end of definition for %s in %s"
                 id-name full-path)
        (break nil))
      (def [_ col end-pos] (find |(= :paren (first $)) m))
      (print (dedent (string/slice src position (inc end-pos))))
      (print)
      (print-c-location id-name line full-path)
      true)
    # janet_quick_asm things such as apply
    # "core/peg" and friends
    # JANET_CORE_DEF things
    (string/has-prefix? `"` trimmed-search-str)
    (let [start-pos (scan-back src "\n" position 2)]
      (unless start-pos
        (eprintf "Failed to find start of definiton for %s in %s"
                 id-name full-path)
        (break nil))
      (def m (peg/match c/c-grammar src start-pos))
      (when (or (nil? m) (empty? m))
        (eprintf "Failed to find end of definition for %s in %s"
                 id-name full-path)
        (break nil))
      # XXX: not so nice
      (var result nil)
      (unless result
        (set result (find |(= :semi-colon (first $)) m)))
      (unless result
        (set result (find |(= :curly (first $)) m)))
      (unless result
        (set result (find |(= :paren (first $)) m)))
      (unless result
        (errorf "oops: %p" m))
      (def col (get result 1))
      (def end-pos (get result 2))
      #
      (print (dedent (string/slice src start-pos (inc end-pos))))
      (print)
      (print-c-location id-name line full-path)
      true)
    # XXX: should not get here
    (do
      (eprintf "Unexpected result for %s" id-name)
      (eprintf "Trimmed search string was: %s" trimmed-search-str))))

(defn handle-janet
  [id-name line position search-str full-path src]
  (let [m (peg/match loc/loc-grammar src position)]
    (if m
      (do
        (def non-ws-tuple
          (find |(and (tuple? $)
                      (not= :whitespace (first $)))
                m))
        (print (loc/gen non-ws-tuple))
        (print)
        (print "``")
        (print "  " id-name)
        (printf "  +%d %s" line full-path)
        (print "``")
        true)
      (do
        (eprintf "Sorry, failed to find definition for: %s" id-name)
        false))))

(defn definition
  [id-name etags-content j-src-path]
  (def etags-table
    (merge ;(peg/match etags/etags-grammar etags-content)))

  (def result (etags-table id-name))

  (unless result
    (break [nil nil
            (string/format "Failed to find: %s" id-name)]))

  (def [line position search-str src-path] result)

  (def full-path
    (string j-src-path "/" src-path))

  (when (not (os/stat full-path))
    (break [nil nil
            (string/format "Failed to find: %s" full-path)]))

  (def src
    (try
      (slurp full-path)
      ([e]
        (break [nil nil e]))))

  (cond
    (string/has-suffix? ".c" src-path)
    (do
      (def buf @"")
      (def ebuf @"")
      (def res
        (with-dyns [*out* buf
                    *err* ebuf]
          (handle-c id-name
                    line position search-str full-path src)))
      (if res
        [res "c" buf]
        [nil nil ebuf]))
    #
    (string/has-suffix? ".janet" src-path)
    (do
      (def buf @"")
      (def ebuf @"")
      (def res
        (with-dyns [*out* buf
                    *err* ebuf]
          (handle-janet id-name
                        line position search-str full-path src)))
      (if res
        [res "janet" buf]
        [nil nil ebuf]))
    #
    [nil nil
     (string/format "Don't know how to handle file: %s" src-path)]))

