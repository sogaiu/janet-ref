(import ./index :as idx)

# capture part of these things, but recognize them so they
# can be navigated "over"
#
# #define JANET_DEFINE_MATH2OP(name, fop, signature, doc)\
# JANET_CORE_FN(janet_##name, signature, doc) {\
#     janet_fixarity(argc, 2); \
#     double lhs = janet_getnumber(argv, 0); \
#     double rhs = janet_getnumber(argv, 1); \
#     return janet_wrap_number(fop(lhs, rhs)); \
# }
#
# #define OPMETHOD(T, type, name, oper) \
# static Janet cfun_it_##type##_##name(int32_t argc, Janet *argv) { \
#     janet_arity(argc, 2, -1); \
#     T *box = janet_abstract(&janet_##type##_type, sizeof(T)); \
#     *box = janet_unwrap_##type(argv[0]); \
#     for (int32_t i = 1; i < argc; i++) \
#         /* This avoids undefined behavior. See above for why. */ \
#         *box = (T) ((uint64_t) (*box)) oper ((uint64_t) janet_unwrap_##type(argv[i])); \
#     return janet_wrap_abstract(box); \
# } \

(def col-one
  ~{:main (some (choice :comment
                        :macro-define
                        :non-macro-match
                        :not-match))
    :non-macro-match (cmt (sequence (look -1 "\n")
                                    (not :s)
                                    (not "#")
                                    (not "}")
                                    (not :label)
                                    (line) (column) (position)
                                    (capture (to "\n"))
                                    "\n")
                          ,|@{:bl $0
                              :bc $1
                              :bp $2
                              :text $3})
    :label (sequence :id ":")
    :id (some (choice :a :d "_"))
    :comment (choice (sequence "//"
                               (any (if-not (set "\r\n") 1)))
                     (sequence "/*"
                               (any (if-not `*/` 1))
                               "*/"))
    :macro-define (choice (cmt (sequence (line) (column) (position)
                                         (capture (sequence "#define" (to "\n")))
                                         "\n")
                               ,|@{:bl $0
                                   :bc $1
                                   :bp $2
                                   :text $3})
                          (cmt (sequence (line) (column) (position)
                                         (capture (sequence "#define" (to `\`)))
                                         `\` "\n"
                                         (some (sequence (thru `\`) "\n"))
                                         # sometimes this is not how it ends
                                         (opt "\n}"))
                               ,|@{:bl $0
                                   :bc $1
                                   :bp $2
                                   :text $3}))
    :not-match 1})

# see comment form below for concrete examples
(defn find-id-for-td-en-st-line
  [line position src]
  (def rev
    (string/reverse line))
  # remember to think backwards as the matching is happening from
  # what was originally the "right" side of the string
  (def g
    '(choice (sequence (choice ";)"
                               ",")
                       (thru "(")
                       (choice (sequence ")"
                                         (capture (choice (to "*")
                                                          (to "("))))
                               (capture (to (set " *")))))
             (sequence ";"
                       (capture (to (set " *"))))
             (sequence "{"
                       :s+
                       (choice (sequence "="
                                         :s+
                                         "]"
                                         (thru "[")
                                         (capture (to (set " *"))))
                               (sequence ")"
                                         (thru "(")
                                         (capture (to (set " *"))))
                               # mune is enum reversed
                               # tcurts is struct reversed
                               (sequence (not "mune")
                                         (not "tcurts")
                                         (capture (to " ")))
                               (constant :reparse)))))
  (def m
    (peg/match g rev))
  # this peg is not for the reversed string
  (def g2
    ~{:main (sequence (some (sequence :id :s+))
                      :curlies
                      :s+ (capture :id) ";")
      :id (some (choice :a :d "_"))
      # XXX: might work with nested because of the source's formatting
      :curlies (sequence "{"
                         (to "\n}")
                         "\n}")})
  #
  (when-let [capture (first m)]
    (if (= :reparse capture)
      (when-let [m2 (peg/match g2 src position)
                 capture-2 (first m2)]
        capture-2)
      # XXX
      #:reparse
      (string/reverse capture))))

(comment

  (find-id-for-td-en-st-line
    "typedef double (win64_variant_f_ffff)(double, double, double, double);"
    nil nil)
  # =>
  "win64_variant_f_ffff"

  (find-id-for-td-en-st-line
    (string "typedef sysv64_sseint_return "
            "janet_sysv64_variant_4(uint64_t a, uint64_t b, uint64_t c, "
            "uint64_t d, uint64_t e, uint64_t f,")
    nil nil)
  # =>
  "janet_sysv64_variant_4"

  (find-id-for-td-en-st-line
    "typedef struct _stat jstat_t;"
    nil nil)
  # =>
  "jstat_t"

  (find-id-for-td-en-st-line
    "enum JanetInstructionType janet_instructions[JOP_INSTRUCTION_COUNT] = {"
    nil nil)
  # =>
  "janet_instructions"

  (find-id-for-td-en-st-line
    "enum JanetParserStatus janet_parser_status(JanetParser *parser) {"
    nil nil)
  # =>
  "janet_parser_status"

  (find-id-for-td-en-st-line
    "enum JanetMemoryType {" nil nil)
  # =>
  "JanetMemoryType"

  (find-id-for-td-en-st-line
    "struct BigNat {" nil nil)
  # =>
  "BigNat"

  (find-id-for-td-en-st-line
    "typedef struct JanetEnvRef {" nil nil)
  # =>
  "JanetEnvRef"

  (find-id-for-td-en-st-line
    "typedef void (*Special)(Builder *b, int32_t argc, const Janet *argv);"
    nil nil)
  # =>
  "Special"

  (def src
    ``
    enum {
        LB_REAL = 200,
        LB_NIL, /* 201 */
        LB_FALSE, /* 202 */
        LB_TRUE,  /* 203 */
        LB_FIBER, /* 204 */
        LB_INTEGER, /* 205 */
        LB_STRING, /* 206 */
        LB_SYMBOL, /* 207 */
        LB_KEYWORD, /* 208 */
        LB_ARRAY, /* 209 */
        LB_TUPLE, /* 210 */
        LB_TABLE, /* 211 */
        LB_TABLE_PROTO, /* 212 */
        LB_STRUCT, /* 213 */
        LB_BUFFER, /* 214 */
        LB_FUNCTION, /* 215 */
        LB_REGISTRY, /* 216 */
        LB_ABSTRACT, /* 217 */
        LB_REFERENCE, /* 218 */
        LB_FUNCENV_REF, /* 219 */
        LB_FUNCDEF_REF, /* 220 */
        LB_UNSAFE_CFUNCTION, /* 221 */
        LB_UNSAFE_POINTER, /* 222 */
        LB_STRUCT_PROTO, /* 223 */
    #ifdef JANET_EV
        LB_THREADED_ABSTRACT, /* 224 */
        LB_POINTER_BUFFER, /* 224 */
    #endif
    } LeadBytes;
    ``)

  (find-id-for-td-en-st-line
    "enum {" 0 src)
  # =>
  "LeadBytes"

  (def src
    ``
    typedef enum {
        JANET_ASYNC_WRITEMODE_WRITE,
        JANET_ASYNC_WRITEMODE_SEND,
        JANET_ASYNC_WRITEMODE_SENDTO
    } JanetWriteMode;
    ``)

  (find-id-for-td-en-st-line
    "typedef enum {" 0 src)
  # =>
  "JanetWriteMode"

  (def src
    ``
    typedef struct {
        JanetEVGenericMessage msg;
        JanetThreadedCallback cb;
        JanetThreadedSubroutine subr;
        JanetHandle write_pipe;
    } JanetEVThreadInit;
    ``)

  (find-id-for-td-en-st-line
    "typedef struct {" 0 src)
  # =>
  "JanetEVThreadInit"

  (def src
    ``
    typedef struct {
        const uint8_t *text_start;
        const uint8_t *text_end;
        const uint32_t *bytecode;
        const Janet *constants;
        JanetArray *captures;
        JanetBuffer *scratch;
        JanetBuffer *tags;
        JanetArray *tagged_captures;
        const Janet *extrav;
        int32_t *linemap;
        int32_t extrac;
        int32_t depth;
        int32_t linemaplen;
        int32_t has_backref;
        enum {
            PEG_MODE_NORMAL,
            PEG_MODE_ACCUMULATE
        } mode;
    } PegState;
    ``)

  (find-id-for-td-en-st-line
    "typedef struct {" 0 src)
  # =>
  "PegState"

  )

(defn find-id-for-rest
  [line]
  (def rev
    (string/reverse line))
  (def has-equals
    (string/find "=" rev))
  (def start
    (inc (or has-equals
             -1)))
  (defn dprintf
    [fmt & args]
    (when (os/getenv "VERBOSE")
      (printf fmt ;args)))
  # XXX
  (dprintf "start: %d" start)
  (dprintf "rev from start: %s" (string/slice rev start))
  (def g
    ~(sequence
       :s*
       # XXX: not the most general
       (any (choice (sequence "/*" (thru `*/`))
                    (sequence (thru "//"))))
       :s*
       (choice
         (sequence ","
                   (thru "(")
                   (cmt (capture (to (set " *")))
                        ,|(do
                            (dprintf ",")
                            $)))
         (sequence "]"
                   (thru "[")
                   (cmt (capture (to (set " *")))
                        ,|(do
                            (dprintf "]")
                            $)))
         (sequence ";"
                   (choice (sequence "]"
                                     (thru "[")
                                     (cmt (capture (to (set " *")))
                                          ,|(do
                                              (dprintf ";]")
                                              $)))
                           (sequence ")"
                                     (constant :declaration))
                           (cmt (capture (to (set " *")))
                                ,|(do
                                    (dprintf "; default")
                                    $))))
         (sequence "{" :s+
                   (choice
                     (sequence ")"
                               (thru "(")
                               (choice (sequence ")"
                                                 (cmt (capture (to (set "*(")))
                                                      ,|(do
                                                          (dprintf "{) up")
                                                          $)))
                                       (cmt (capture (to (choice (set " *")
                                                                 -1)))
                                            ,|(do
                                                (dprintf "{) down")
                                                $))))
                     (cmt (capture (to (set " *")))
                          ,|(do
                              (dprintf "{ default")
                              $))))
         (sequence "("
                   (cmt (capture (to (set " *")))
                        ,|(do
                            (dprintf "(")
                            $)))
         (cmt (capture (to (set " *")))
              ,|(do
                  (dprintf "default")
                  $)))))
  #
  (def m
    (peg/match g rev start))
  # XXX
  (dprintf "%p" m)
  #
  (when-let [capture (first m)]
    (if (= :declaration capture)
      :declaration
      (string/reverse capture))))

(comment

  #(os/setenv "VERBOSE" "1")

  (find-id-for-rest
    "const char *const janet_signal_names[14] = {")
  # =>
  "janet_signal_names"

  (find-id-for-rest
    "static char error_clib_buf[256];")
  # =>
  "error_clib_buf"

  (find-id-for-rest
    "static int cfun_io_gc(void *p, size_t len);")
  # =>
  :declaration

  (find-id-for-rest
    "JANET_THREAD_LOCAL JanetVM janet_vm;")
  # =>
  "janet_vm"

  (find-id-for-rest
    "double (janet_unwrap_number)(Janet x) {")
  # =>
  "janet_unwrap_number"

  (find-id-for-rest
    "const Janet *(janet_unwrap_tuple)(Janet x) {")
  # =>
  "janet_unwrap_tuple"

  (find-id-for-rest
    "os_proc_wait_impl(JanetProc *proc) {")
  # =>
  "os_proc_wait_impl"

  (find-id-for-rest
    "const void *janet_strbinsearch(")
  # =>
  "janet_strbinsearch"

  (find-id-for-rest
    "static const JanetAbstractType janet_struct_type = {")
  # =>
  "janet_struct_type"

  (find-id-for-rest
    "static void janetc_movenear(JanetCompiler *c,")
  # =>
  "janetc_movenear"

  )

(defn find-id-for-macro-define
  [line]
  (def g
    ~(sequence "#define" :s+
               (capture (to (set " (")))))
  (def m
    (peg/match g line))

  (first m))

(comment

  (find-id-for-macro-define
    "#define A ((*pc >> 8)  & 0xFF)")
  # =>
  "A"

  (find-id-for-macro-define
    (string "#define janet_v_free(v)         "
            "(((v) != NULL) ? (janet_sfree(janet_v__raw(v)), 0) : 0)"))
  # =>
  "janet_v_free"

  (find-id-for-macro-define
    "#define vm_throw(e) do { vm_commit(); janet_panic(e); } while (0)")
  # =>
  "vm_throw"

  (find-id-for-macro-define
    "#define JANET_EMIT_H")
  # =>
  nil

  )

(defn separate-lines
  [samples]
  (def scan-from-right @[])
  # typedef, enum, struct
  (def td-en-st @[])
  (def macro-defines @[])
  (def unmatched @[])
  (loop [i :in samples]
    (def s (get i :text))
    (when (not (or (string/has-prefix? "extern " s)
                   (peg/match '(sequence (some (range "AZ" "09" "__"))
                                         "(")
                              s)))
      (cond
        (or (string/has-prefix? "typedef " s)
            (string/has-prefix? "enum " s)
            (string/has-prefix? "struct " s))
        (array/push td-en-st i)
        #
        (string/has-prefix? "#define" s)
        (array/push macro-defines i)
        #
        (not (peg/match '(some (choice :a :d "_"))
                        (string/reverse s)))
        (array/push scan-from-right i)
        # for introspection
        (array/push unmatched i))))
  #
  [scan-from-right td-en-st macro-defines unmatched])

(comment

  (def dir
    (string (os/getenv "HOME")
            "/src/janet/src/core"))

  (def samples
    (seq [path :in (os/dir dir)
          :let [full-path (string dir "/" path)
                src (slurp full-path)]
          item :in (peg/match col-one src)]
      # XXX: src or path?
      (put item :src src)))

  (def [scan-from-right td-en-st macro-defines unmatched]
    (separate-lines samples))

  (var cnt 0)

  (each i (sort-by |(get $ :text) td-en-st)
    (def s
      (get i :text))
    (def position
      (get i :bp))
    (def src
      (get i :src))
    (def result
      (find-id-for-td-en-st-line s position src))
    (when (string? result)
      (++ cnt))
    (printf "%p" result))

  (each i (sort-by |(get $ :text) scan-from-right)
    (def s
      (get i :text))
    (def result (find-id-for-rest s))
    (when (string? result)
      (++ cnt))
    (printf "%p" result))

  (each i (sort-by |(get $ :text) macro-defines)
    (def s
      (get i :text))
    (def result
      (find-id-for-macro-define s))
    (when (string? result)
      (++ cnt))
    (printf "%p" result))

  # 1293, 1629
  cnt

  )

########################################################################

(defn find-c-tags
  [src]

  (def results @[])

  '(def src
     (slurp
       (string (os/getenv "HOME") "/src/janet/src/core/math.c")))

  '(def src
     (slurp
       (string (os/getenv "HOME") "/src/janet/src/core/ev.c")))

  '(def src
     (slurp
       (string (os/getenv "HOME") "/src/janet/src/core/vector.h")))

  (def caps
    (peg/match col-one src))

  (def [scan-from-right td-en-st macro-defines unmatched]
    (separate-lines caps))

  # XXX: what about duplicates?
  (each item scan-from-right
    (def line
      (get item :text))
    (def id-maybe
      (find-id-for-rest line))
    (when (string? id-maybe)
      (def line-no
        (get item :bl))
      (def pos
        (get item :bp))
      (array/push results
                  [line
                   id-maybe
                   (string line-no)
                   (string pos)])))
  # XXX: what about duplicates?
  (each item td-en-st
    (def line
      (get item :text))
    (def pos
      (get item :bp))
    (def id-maybe
      (find-id-for-td-en-st-line line pos src))
    (when (string? id-maybe)
      (def line-no
        (get item :bl))
      (array/push results
                  [line
                   id-maybe
                   (string line-no)
                   (string pos)])))
  # XXX: what about duplicates?
  (each item macro-defines
    (def line
      (get item :text))
    (def pos
      (get item :bp))
    (def id-maybe
      (find-id-for-macro-define line))
    (when (string? id-maybe)
      (def line-no
        (get item :bl))
      (array/push results
                  [line
                   id-maybe
                   (string line-no)
                   (string pos)])))
  # enum constants
  (each item td-en-st
    (def line
      (get item :text))
    (def pos
      (get item :bp))
    (when (or (and (string/has-prefix? "enum " line)
                   (string/has-suffix? "{" line))
              (and (string/has-prefix? "typedef enum " line)
                   (string/has-suffix? "{" line)))
      (def m
        (peg/match
          ~{:main (sequence (opt (sequence "typedef" :s+))
                            "enum" :s+
                            (opt (sequence :id :s+))
                            "{" "\n"
                            (some (cmt (sequence (not "}")
                                                 (line) (column) (position)
                                                 (capture (to "\n")) "\n")
                                       ,|@{:bl $0
                                           :bc $1
                                           :bp $2
                                           :text $3})))
            :id (some (choice :a :d "_"))}
          src pos))
      (when m
        (each item m
          (def line-no
            (get item :bl))
          (def pos
            (get item :bp))
          (def line
            (get item :text))
          (def trimmed
            (string/trim line))
          (def id
            (string/slice trimmed
                          0 (or (string/find "," trimmed)
                                -1)))
          (array/push results
                      [line
                       id
                       (string line-no)
                       (string pos)])))))
  #
  results)

########################################################################

(defn index-c!
  [src path out-buf]
  (idx/index-file! src path find-c-tags out-buf))

