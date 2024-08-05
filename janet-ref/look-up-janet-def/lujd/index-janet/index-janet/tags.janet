(import ./etags)

(def parse-peg
  '(sequence :s*
             "("
             (capture (to :s))
             :s))

(defn to-tags-kind
  [text]
  (def compiled-peg
    (peg/compile parse-peg))
  (if-let [[extracted] (peg/match compiled-peg text)]
    (case extracted
      "def" "d"
      "def-" "D"
      "defglobal" "g"
      "varglobal" "G"
      "defmacro" "m"
      "defmacro-" "M"
      "defn" "n"
      "defn-" "N"
      "varfn" "r"
      "var" "v"
      "var-" "V"
      "defdyn" "y"
      (errorf "Unexpected item: %p" extracted))
    "f"))

(comment

  (to-tags-kind
    "JANET_CORE_FN(cfun_tuple_brackets,")
  # =>
  "f"

  (to-tags-kind
    "(def defn :macro")
  # =>
  "d"

  (to-tags-kind
    "  (defn .disasm")
  # =>
  "n"

  (to-tags-kind
    (string `  `
            `(defdyn *ffi-context* " `
            `Current native library for ffi/bind and other settings")`))
  # =>
  "y"

  )

(comment

  '@[@{}
     @{"tuple/brackets"
       @[58 2136 "JANET_CORE_FN(cfun_tuple_brackets," "src/core/tuple.c"]
       "tuple/setmap"
       @[108 4432 "JANET_CORE_FN(cfun_tuple_setmap," "src/core/tuple.c"]
       "tuple/slice"
       @[66 2433 "JANET_CORE_FN(cfun_tuple_slice," "src/core/tuple.c"]
       "tuple/sourcemap"
       @[96 3928 "JANET_CORE_FN(cfun_tuple_sourcemap," "src/core/tuple.c"]
       "tuple/type"
       @[80 3259 "JANET_CORE_FN(cfun_tuple_type," "src/core/tuple.c"]}
     @{}
     @{}]

  '@[@{}
     @{"tuple/brackets"
       @[58 "JANET_CORE_FN(cfun_tuple_brackets," "src/core/tuple.c"]
       "tuple/setmap"
       @[108 "JANET_CORE_FN(cfun_tuple_setmap," "src/core/tuple.c"]
       "tuple/slice"
       @[66 "JANET_CORE_FN(cfun_tuple_slice," "src/core/tuple.c"]
       "tuple/sourcemap"
       @[96 "JANET_CORE_FN(cfun_tuple_sourcemap," "src/core/tuple.c"]
       "tuple/type"
       @[80 "JANET_CORE_FN(cfun_tuple_type," "src/core/tuple.c"]}
     @{}
     @{}]

  )

(defn etags-to-tags
  [etags-buf]
  (def out-lines @[])
  (def parsed
    (peg/match etags/etags-grammar etags-buf))
  (each dict parsed
    (eachp [id info] dict
      (def line (first info))
      (def text
        (if (= 3 (length info))
          (get info 1)
          (get info 2)))
      (def path (last info))
      # XXX: tabs in text could cause problems if instead of line
      #      text converted to a regular expression is used
      (array/push out-lines
                  (string id "\t"
                          path "\t"
                          line "\t"
                          `;" ` (to-tags-kind text)))))
  #
  (sort out-lines))

(comment

  (def etags-buf
    @``
     
     src/boot/boot.janet,15056
     (def defn :macrodefn10,106
     (defn defmacro :macrodefmacro45,1087
     (defmacro as-macroas-macro51,1265
     (defmacro defmacro-defmacro-59,1557

     ``)

  (etags-to-tags etags-buf)
  # =>
  '@["as-macro\tsrc/boot/boot.janet\t51\t;\" m"
     "defmacro\tsrc/boot/boot.janet\t45\t;\" n"
     "defmacro-\tsrc/boot/boot.janet\t59\t;\" m"
     "defn\tsrc/boot/boot.janet\t10\t;\" d"]

  )

