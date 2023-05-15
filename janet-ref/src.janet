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
  (print "/*")
  (print "   " id)
  (printf "   +%d %s" line full-path)
  (print "*/"))

# JANET_DEFINE_MATHOP(acos, "Returns the arccosine of x.")
#
# JANET_DEFINE_NAMED_MATHOP("log-gamma", lgamma, "Returns log-gamma(x).")
#
# JANET_DEFINE_MATH2OP(pow, pow, "(math/pow a x)", "Returns a to the power of x.")
#
# static JanetSlot janetc_quote(JanetFopts opts, int32_t argn, const Janet *argv) {
#
# janet_quick_asm(env, JANET_FUN_APPLY | JANET_FUNCDEF_FLAG_VARARG,
#                 "apply", 1, 1, INT32_MAX, 6, apply_asm, sizeof(apply_asm),
#                 ...);
#
# janet_quick_asm(env, JANET_FUN_MODULO,
#                 "mod", 2, 2, 2, 2, modulo_asm, sizeof(modulo_asm),
#                 JDOC("(mod dividend divisor)\n\n"
#                      "Returns the modulo of dividend / divisor."));
#
# templatize_varop(env, JANET_FUN_MULTIPLY, "*", 1, 1, JOP_MULTIPLY,
#                  JDOC("(* & xs)\n\n"
#                       "Returns the product ... returns 1."));
#
# templatize_comparator(env, JANET_FUN_GT, ">", 0, JOP_GREATER_THAN,
#                       JDOC("(> & xs)\n\n"
#                       "Check if xs is in ... Returns a boolean."));
#
# janet_def(env, "janet/version", janet_cstringv(JANET_VERSION),
#           JDOC("The version number of the running janet program."));
#
# JANET_CORE_FN(cfun_peg_compile,
#              "(peg/compile peg)", ...)
#
# const JanetAbstractType janet... = {
#     "core/file",
#     ...
# };
#
# #ifdef JANET_BOOTSTRAP
#     JANET_CORE_DEF(env, "math/pi", janet_wrap_number(3.1415926535897931),
#                    ...);
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

(def match-table
  {"JANET_DEFINE_MATHOP" [:paren]
   "JANET_DEFINE_NAMED_MATHOP" [:paren]
   "JANET_DEFINE_MATH2OP" [:paren]
   "static" [:curly]
   "janet_quick_asm" [:semi-colon]
   "templatize_varop" [:semi-colon]
   "templatize_comparator" [:semi-colon]
   "janet_def" [:semi-colon]
   "JANET_CORE_FN" [:curly]
   "const JanetAbstractType" [:semi-colon]
   "JANET_CORE_DEF" [:semi-colon]})

(defn handle-c
  [id-name line position search-str full-path src]
  (def trimmed-search-str
    (string/trim search-str))
  # try to establish the start of the definition
  (def start-pos
    (if (string/has-prefix? `"` trimmed-search-str)
      (scan-back src "\n" position 2)
      position))
  (unless start-pos
    (eprintf "Failed to find start of definiton for %s in %s"
             id-name full-path)
    (break nil))
  # match-str is used as part of determining type of definition
  (def match-str
    (if (string/has-prefix? `"` trimmed-search-str)
      # need to look backward in src for a number of cases
      (-> src
          (string/slice start-pos position)
          string/trim)
      # easy cases of not having to look backward
      trimmed-search-str))
  # use match-str and match-table to figure out "end of def" marker
  (def [_ match-type]
    (->> (pairs match-table)
         (find |(string/has-prefix? (first $) match-str))))
  (unless match-type
    (eprintf "Unexpected result for %s" id-name)
    (eprintf "Trimmed search string was: %s" trimmed-search-str)
    (break nil))
  # try to find the end of the definition
  (def m (peg/match c/c-grammar src start-pos))
  (when (or (nil? m) (empty? m))
    (eprintf "Failed to find end of definition for %s in %s"
             id-name full-path)
    (break nil))
  #
  (var result nil)
  (each end-of-def-marker match-type
    (set result (find |(= end-of-def-marker (first $)) m))
    (when result (break)))
  (unless result
    (eprintf "Failed to locate sentinel(s): %p" match-type)
    (break nil))
  (def [_ col end-pos] result)
  # print out definition
  (print (dedent (string/slice src start-pos (inc end-pos))))
  (print)
  (print-c-location id-name line full-path)
  true)

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

# XXX: might be a faster way to do this, but this was easy
(defn find-position
  [line src]
  (def lines
    (string/split "\n" src))
  (def pos
    (reduce (fn [acc a-line]
              (+ acc
                 (length a-line)
                 1)) # newline length
            0
            (array/slice lines 0 (dec line))))
  #
  pos)

(comment

  (def first-line
    "This is line one\n")

  (def second-line
    "This is line two\n")

  (find-position 3
                 (string first-line
                         second-line
                         "This is line three"))
  # =>
  (+ (length first-line)
     (length second-line))

  )

(defn definition
  [id-name etags-content j-src-path]
  (def etags-table
    (merge ;(peg/match etags/etags-grammar etags-content)))

  (def result (etags-table id-name))

  (unless result
    (break [nil nil
            (string/format "Failed to find: %s" id-name)]))

  (def line (first result))

  (def search-str
    (if (= 3 (length result))
      (get result 1)
      (get result 2)))

  (def src-path (last result))

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

  (def position
    (find-position line src))

  (unless position
    (errorf "Failed to find position for: %s" id-name))

  (cond
    (or (string/has-suffix? ".c" src-path)
        (string/has-suffix? ".h" src-path))
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

