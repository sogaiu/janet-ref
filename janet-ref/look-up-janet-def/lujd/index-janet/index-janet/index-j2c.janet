(import ./index :as idx)

########################################################################

(defn find-math-c-tags
  [src]

  '(def src
    (slurp
      (string (os/getenv "HOME") "/src/janet/src/core/math.c")))

  # JANET_DEFINE_MATHOP(acos, "Returns the arccosine of x.")
  # ...
  # JANET_DEFINE_NAMED_MATHOP("log-gamma", lgamma, "Returns log-gamma(x).")
  # ...
  # JANET_DEFINE_MATH2OP(pow, pow, "(math/pow a x)", "Returns a to the power of x.")
  # ...

  (def query-peg
    ~{:main (some (choice :match
                          :non-match))
      :id (some (choice :a :d "_"))
      :match
      (sequence "\n"
                (choice (sequence "JANET_DEFINE_NAMED_MATHOP" "("
                                  (cmt (sequence `"`
                                                 (line) (column) (position)
                                                 (capture (to `"`)))
                                       ,|[$0 $1 $2 (string "math/" $3)]))
                        #
                        (sequence "JANET_DEFINE_MATH2OP" "("
                                  :id "," :s+
                                  :id "," :s+
                                  (cmt (sequence `"(`
                                                 (line) (column) (position)
                                                 (capture (to (set " )"))))
                                       ,|[$0 $1 $2 $3]))
                        #
                        (sequence "JANET_DEFINE_MATHOP" "("
                                  (cmt (sequence (line) (column) (position)
                                                 (capture :id))
                                       ,|[$0 $1 $2 (string "math/" $3)]))))
      :non-match 1})

  (def caps
    (peg/match query-peg src))

  (idx/get-all-pieces src caps))

(defn find-specials-c-tags
  [src]

  '(def src
    (slurp
      (string (os/getenv "HOME") "/src/janet/src/core/specials.c")))

  # static JanetSlot janetc_quote(JanetFopts opts, int32_t argn, const Janet *argv) {
  # ...
  # static JanetSlot janetc_varset(JanetFopts opts, int32_t argn, const Janet *argv) {
  # ...

  (def query-peg
    ~{:main (some (choice :match
                          :non-match))
      :id (some (choice :a :d "_"))
      :match (sequence "\n" "static JanetSlot" :s+
                       (cmt (sequence (line) (column) (position)
                                      (capture :id))
                            ,(fn [l c p id]
                               (def prefix "janetc_")
                               (when (string/has-prefix? prefix id)
                                 (def short-name
                                   (string/slice id (length prefix)))
                                 (def real-name
                                   (if (= "varset" short-name)
                                     "set"
                                     short-name))
                                 [l c p real-name]))))
      :non-match 1})

  (def caps
    (peg/match query-peg src))

  (idx/get-all-pieces src caps))

(defn find-corelib-c-tags
  [src]

  '(def src
    (slurp
      (string (os/getenv "HOME") "/src/janet/src/core/corelib.c")))

  # janet_quick_asm(env, JANET_FUN_APPLY | JANET_FUNCDEF_FLAG_VARARG,
  #                 "apply", 1, 1, INT32_MAX, 6, apply_asm, sizeof(apply_asm),
  # ...
  # janet_quick_asm(env, JANET_FUN_MODULO,
  #                 "mod", 2, 2, 2, 2, modulo_asm, sizeof(modulo_asm),
  #                 JDOC("(mod dividend divisor)\n\n"
  #                      "Returns the modulo of dividend / divisor."));
  # ...
  # templatize_varop(env, JANET_FUN_MULTIPLY, "*", 1, 1, JOP_MULTIPLY,
  #                  JDOC("(* & xs)\n\n"
  #                       "Returns the product ... returns 1."));
  # ...
  # templatize_comparator(env, JANET_FUN_GT, ">", 0, JOP_GREATER_THAN,
  #                       JDOC("(> & xs)\n\n"
  #                       "Check if xs is in ... Returns a boolean."));
  # ...
  # janet_def(env, "janet/version", janet_cstringv(JANET_VERSION),
  #           JDOC("The version number of the running janet program."));

  (def query-peg
    ~{:main (some (choice :match
                          :non-match))
      :id (some (choice :a :d "_"))
      :match
      (sequence
        ";\n"
        # * the /* ... */ part is for +, >, janet/version, root-env
        (opt (sequence :s+
                       "/*"
                       (some (if-not "*/" 1))
                       "*/"))
        :s+
        (choice (sequence (choice "janet_quick_asm"
                                  "templatize_varop"
                                  "templatize_comparator")
                          "("
                          :id
                          "," :s+
                          :id (opt (sequence :s+ "|" :s+ :id)) # opt for apply
                          "," :s+
                          (cmt (sequence `"`
                                         (line) (column) (position)
                                         (capture (to `"`))
                                         `"`)
                               ,|[$0 $1 $2 $3]))
                (sequence "janet_def"
                          "("
                          :id "," :s+
                          (cmt (sequence `"`
                                         (line) (column) (position)
                                         (capture (to `"`))
                                         `"`)
                               ,|[$0 $1 $2 $3]))))
      :non-match 1})

  (def caps
    (peg/match query-peg src))

  (idx/get-all-pieces src caps))

# JANET_CORE_DEF
# * io.c
# * math.c
(defn find-janet-core-def-tags
  [src]

  '(def src
    (slurp
      (string (os/getenv "HOME") "/src/janet/src/core/io.c")))

  '(def src
    (slurp
      (string (os/getenv "HOME") "/src/janet/src/core/math.c")))

  # #ifdef JANET_BOOTSTRAP
  #     JANET_CORE_DEF(env, "math/pi", janet_wrap_number(3.1415926535897931),
  #                    ...);
  # ...
  #
  # note that leading whitespace is elided from sample of io.c below
  #
  # int default_flags = JANET_FILE_NOT_CLOSEABLE | JANET_FILE_SERIALIZABLE;
  # /* stdout */
  # JANET_CORE_DEF(env, "stdout",
  #                ...);
  # /* stderr */
  # JANET_CORE_DEF(env, "stderr",
  #                ...);

  (def query-peg
    ~{:main (some (choice :match
                          :non-match))
      :id (some (choice :a :d "_"))
      :match (sequence (choice ";" :id)
                       (opt (sequence :s+
                                      "/*"
                                      (some (if-not "*/" 1))
                                      "*/"))
                       :s+
                       "JANET_CORE_DEF"
                       "("
                       :id "," :s+
                       (cmt (sequence `"`
                                      (line) (column) (position)
                                      (capture (to `"`))
                                      `"`)
                            ,|[$0 $1 $2 $3]))
      :non-match 1})

  (def caps
    (peg/match query-peg src))

  (idx/get-all-pieces src caps))

# JANET_CORE_FN
# * many
(defn find-janet-core-fn-tags
  [src]

  '(def src
     (slurp
       (string (os/getenv "HOME") "/src/janet/src/core/ffi.c")))

  '(def src
     (slurp
       (string (os/getenv "HOME") "/src/janet/src/core/math.c")))

  # JANET_CORE_FN(cfun_peg_compile,
  #              "(peg/compile peg)", ...)

  (def query-peg
    ~{:main (some (choice :match
                          :non-match))
      :id (some (choice :a :d "_"))
      :match (sequence (choice ";"  # parser/state, etc.
                               ")"  # math/pow, etc.
                               "}"  # ev/acquire-lock, etc.
                               "*/" # module/expand-path, etc.
                               :id) # ffi/signature, etc.
                       (choice (sequence :s+
                                         "/*"
                                         (some (if-not "*/" 1))
                                         "*/"
                                         :s+)
                               :s+)
                       "JANET_CORE_FN" "(" :id "," :s+
                       # e.g. "(file/temp)" or "(peg/compile peg)"
                       (cmt (sequence `"(`
                                      (line) (column) (position)
                                      (capture (to (choice (set ` )`)
                                                           # janet 1.17.0 has
                                                           # an error in doc
                                                           # for
                                                           # fiber/last-value
                                                           `"`))))
                            ,|[$0 $1 $2 $3]))
      :non-match 1})

  (def caps
    (peg/match query-peg src))

  (idx/get-all-pieces src caps))

# const JanetAbstractType janet... = {
# * many
(defn find-janet-abstract-type-tags
  [src]

  '(def src
     (slurp
       (string (os/getenv "HOME") "/src/janet/src/core/ev.c")))

  '(def src
     (slurp
       (string (os/getenv "HOME") "/src/janet/src/core/ffi.c")))

  # const JanetAbstractType janet... = {
  #     "core/file",
  #     ...
  # };

  (def query-peg
    ~{:main (some (choice :match
                          :non-match))
      :id (some (choice :a :d "_"))
      :match (sequence "const" :s+
                       "JanetAbstractType" :s+
                       :id :s+ "="
                       :s+ "{" :s+
                       (cmt (sequence `"`
                                      (line) (column) (position)
                                      (capture (some (if-not `"` 1)))
                                      `"`)
                            ,|[$0 $1 $2 $3]))
      :non-match 1})

  (def caps
    (peg/match query-peg src))

  (idx/get-all-pieces src caps))

########################################################################

(defn index-math-c!
  [src path out-buf]
  (idx/index-file! src path find-math-c-tags out-buf))

(defn index-specials-c!
  [src path out-buf]
  (idx/index-file! src path find-specials-c-tags out-buf))

(defn index-corelib-c!
  [src path out-buf]
  (idx/index-file! src path find-corelib-c-tags out-buf))

(defn index-janet-core-def-c!
  [src path out-buf]
  (idx/index-file! src path find-janet-core-def-tags out-buf))

(defn index-generic-c!
  [src path out-buf]
  (try
    (idx/index-file! src path find-janet-abstract-type-tags out-buf)
    ([e]
      (eprintf "%s: abstract - %p" path e)))
  (try
    (idx/index-file! src path find-janet-core-fn-tags out-buf)
    ([e]
      (eprintf "%s: core-fn - %p" path e))))

