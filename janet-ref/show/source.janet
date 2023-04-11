(import ../highlight/highlight :as hl)
(import ../parse/c :as c)
(import ../parse/etags :as etags)
(import ../parse/location :as loc)

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

  # XXX: file existence check?
  (def src (slurp full-path))

  (cond
    (string/has-suffix? ".c" src-path)
    (let [m (peg/match c/c-grammar src position)
          trimmed-search-str (string/trim search-str)]
      (unless m
        (printf "Sorry, failed to find definition for: %s" id-name)
        (break false))
      (cond
        (or (string/has-prefix? "JANET_CORE_FN" trimmed-search-str)
            (string/has-prefix? "static" trimmed-search-str))
        (let [[_ col end-pos] (find |(= :curly (first $)) m)]
          (assert (= col 1)
                  (string/format "Unexpected col value: %d" col))
          (printf "// %s +%d %s\n" id-name line full-path)
          # XXX: need c-colorize
          #(print (hl/c-colorize (string/slice src position (inc end-pos))))
          (print (string/slice src position (inc end-pos))))
        #
        (or (string/has-prefix? "JANET_CORE_DEF" trimmed-search-str)
            (string/has-prefix? "janet_quick_asm" trimmed-search-str)
            (string/has-prefix? "janet_def" trimmed-search-str)
            (string/has-prefix? "templatize_comparator" trimmed-search-str)
            (string/has-prefix? "templatize_varop" trimmed-search-str))
        (let [[_ col end-pos] (find |(= :semi-colon (first $)) m)]
          (printf "// %s +%d %s\n" id-name line full-path)
          # XXX: need c-colorize
          #(print (hl/c-colorize (string/slice src position (inc end-pos))))
          (print (string/slice src position (inc end-pos))))
        # XXX: not yet handling core/peg and friends
        # XXX: should not get here
        (do
          (eprintf "Unexpected result for %s" id-name)
          (eprintf "Trimmed search string was: %s" trimmed-search-str))))
    #
    (string/has-suffix? ".janet" src-path)
    (let [m
          (peg/match (-> (struct/to-table loc/loc-grammar)
                         # customizing grammar to just get one form
                         (put :main :input))
                     src position)]
      (if m
        (do
          (printf "# %s +%d %s\n" id-name line full-path)
          (print (hl/colorize (loc/gen (first m))))
          true)
        (do
          (printf "Sorry, failed to find definition for: %s" id-name)
          false)))
    #
    (errorf "Don't know how to handle file: %s" src-path)))

