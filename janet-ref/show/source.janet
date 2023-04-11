(import ../highlight/highlight :as hl)
(import ../parse/c :as c)
(import ../parse/etags :as etags)
(import ../parse/location :as loc)

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

(defn handle-c
  [id-name line position search-str full-path src]
  (def trimmed-search-str
    (string/trim search-str))
  (cond
    (or (string/has-prefix? "JANET_CORE_FN" trimmed-search-str)
        (string/has-prefix? "static" trimmed-search-str))
    (let [m (peg/match c/c-grammar src position)]
      (when (or (nil? m) (empty? m))
        (eprintf "Failed to find end of definition for %s in %s"
                 id-name full-path)
        (break nil))
      (def [_ col end-pos] (find |(= :curly (first $)) m))
      (assert (= col 1)
              (string/format "Unexpected col value: %d" col))
      # XXX: need c-colorize
      #(print (hl/c-colorize (string/slice src position (inc end-pos))))
      (print (dedent (string/slice src position (inc end-pos))))
      (print)
      (print "//" id-name)
      (printf "+%d %s\n" line full-path)
      true)
    #
    (or (string/has-prefix? "JANET_CORE_DEF" trimmed-search-str)
        (string/has-prefix? "janet_quick_asm" trimmed-search-str)
        (string/has-prefix? "janet_def" trimmed-search-str)
        (string/has-prefix? "templatize_comparator" trimmed-search-str)
        (string/has-prefix? "templatize_varop" trimmed-search-str))
    (let [m (peg/match c/c-grammar src position)]
      (when (or (nil? m) (empty? m))
        (eprintf "Failed to find end of definition for %s in %s"
                 id-name full-path)
        (break nil))
      (def [_ col end-pos] (find |(= :semi-colon (first $)) m))
      # XXX: need c-colorize
      #(print (hl/c-colorize (string/slice src position (inc end-pos))))
      (print (dedent (string/slice src position (inc end-pos))))
      (print)
      (print "//" id-name)
      (printf "+%d %s\n" line full-path)
      true)
    # "core/peg" and friends
    (and (string/has-prefix? `"` trimmed-search-str)
         (string/has-suffix? `",` trimmed-search-str))
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
      (def [_ col end-pos] (find |(= :semi-colon (first $)) m))
      # XXX: need c-colorize
      #(print (hl/c-colorize (string/slice src start-pos (inc end-pos))))
      (print (dedent (string/slice src start-pos (inc end-pos))))
      (print)
      (print "//" id-name)
      (printf "+%d %s\n" line full-path)
      true)
    # XXX: should not get here
    (do
      (eprintf "Unexpected result for %s" id-name)
      (eprintf "Trimmed search string was: %s" trimmed-search-str))))

(defn handle-janet
  [id-name line position search-str full-path src]
  (let [m
        (peg/match (-> (struct/to-table loc/loc-grammar)
                       # customizing grammar to just get one form
                       (put :main :input))
                   src position)]
    (if m
      (do
        (print (hl/colorize (loc/gen (first m))))
        (print)
        (print "#" id-name)
        (printf "+%d %s\n" line full-path)
        true)
      (do
        (printf "Sorry, failed to find definition for: %s" id-name)
        false))))

(defn definition
  [id-name]
  # XXX: dir existence check? better to do before calling?
  (def j-src-path
    (dyn :jref-janet-src-path))

  (when (not (os/stat j-src-path))
    (eprintf "Janet source not available at: %s" j-src-path)
    (eprint "Set JREF_JANET_SRC_PATH to Janet source directory?")
    (break nil))

  (def etags-file-path
    (string j-src-path "/TAGS"))

  (when (not (os/stat etags-file-path))
    (eprintf "Failed to find TAGS file in Janet source directory: %s"
             j-src-path)
    (eprintf "Hint: use index-janet-source's idk-janet to create it")
    (break nil))

  (def etags-content
    (slurp etags-file-path))

  (def etags-table
    (merge ;(peg/match etags/etags-grammar etags-content)))

  (def [line position search-str src-path]
    (etags-table id-name))

  (def full-path
    (string j-src-path
            "/"
            src-path))

  (when (not (os/stat full-path))
    (eprintf "Failed to find: %s" full-path)
    (break nil))

  (def src (slurp full-path))

  (cond
    (string/has-suffix? ".c" src-path)
    (handle-c id-name line position search-str full-path src)
    #
    (string/has-suffix? ".janet" src-path)
    (handle-janet id-name line position search-str full-path src)
    #
    (errorf "Don't know how to handle file: %s" src-path)))

