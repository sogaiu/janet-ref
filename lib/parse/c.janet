```
Parsing relevant C things for finding definition code

The following methods may cover all the sorts of things we want to
extract from Janet's C source.

Given a starting point for an idenitifer, do one of the following
depending on the "search string":

* look until ); skipping things including strings
  (search strings have leading space below)
  *     JANET_CORE_DEF
  *     janet_quick_asm
  *     janet_def
  *     templatize_comparator
  *     templatize_varop

* find first opening curly, then closing curly (may be in column 0),
  depending on method may need to skip strings
  * JANET_CORE_FN
  * static ...

* backtrack to (previous line?) find first curly
  brace first, then look until }; (closing curly might be in column 0)
  (search strings have leading spaces below)
  *     "core/rng"
  *     "core/stream"
  * etc.

```

# https://en.wikipedia.org/wiki/Escape_sequences_in_C#Table_of_escape_sequences
(def c-grammar
  ~{:main (some :input)
    :input (choice :whitespace
                   :comment
                   :other)
    :other (choice :string
                   :non-string
                   :paren-bound
                   :curly-bound
                   :semi-colon)
    :string (sequence `"`
                      (any (choice :escape
                                   (if-not `"` 1)))
                      `"`)
    :escape (sequence `\`
                      (choice (set `abefnrtv\'"?`)
                              (between 1 3 (range "07"))
                              (sequence "x" :d+)
                              (sequence "u" (4 :h))
                              (sequence "U" (8 :h))))
    :non-string (some (choice :a
                              :d
                              # XXX: @, $, and ` not allowed in C?
                              (set `_+-/*.,=&|!^~%?:[]<>#\'`)))
    :paren-bound (cmt (sequence "("
                                (capture (any :input))
                                (column) (position)
                                ")")
                      ,(fn [& args]
                         [:paren ;(slice args -3)]))
    :curly-bound (cmt (sequence "{"
                                (any :input)
                                (column) (position)
                                "}")
                      ,(fn [& args]
                         [:curly ;(slice args -3)]))
    :semi-colon (cmt (sequence (column) (position) ";")
                     ,|[:semi-colon $0 $1])
    # XXX: incomplete?
    :whitespace (some (set " \f\n\r\t\v"))
    :comment (choice :line-comment
                     :multi-line-comment)
    :line-comment (sequence "//"
                            (any (if-not (set "\r\n") 1)))
    :multi-line-comment (sequence "/*"
                                  (any (if-not `*/` 1))
                                  "*/")})

(comment

  (def janet-core-fn-src
    ``
    JANET_CORE_FN(cfun_rng_make,
                  "(math/rng &opt seed)",
                  "Creates a Psuedo-Random number generator, with an optional seed. "
                  "The seed should be an unsigned 32 bit integer or a buffer. "
                  "Do not use this for cryptography. Returns a core/rng abstract type."
                 ) {
        janet_arity(argc, 0, 1);
        JanetRNG *rng = janet_abstract(&janet_rng_type, sizeof(JanetRNG));
        if (argc == 1) {
            if (janet_checkint(argv[0])) {
                uint32_t seed = (uint32_t)(janet_getinteger(argv, 0));
                janet_rng_seed(rng, seed);
            } else {
                JanetByteView bytes = janet_getbytes(argv, 0);
                janet_rng_longseed(rng, bytes.bytes, bytes.len);
            }
        } else {
            janet_rng_seed(rng, 0);
        }
        return janet_wrap_abstract(rng);
    }
    ``)

  (peg/match c-grammar janet-core-fn-src)
  # =>
  '@[(:paren 14 322) (:curly 1 827)]

  (def static-src
    ``
    static JanetSlot janetc_quote(JanetFopts opts, int32_t argn, const Janet *argv) {
        if (argn != 1) {
            janetc_cerror(opts.compiler, "expected 1 argument to quote");
            return janetc_cslot(janet_wrap_nil());
        }
        return janetc_cslot(argv[0]);
    }
    ``)

  (peg/match c-grammar static-src)
  # =>
  '@[(:paren 79 78) (:curly 1 260)]

  (def static-src-2
    ``
    static JanetSlot janetc_def(JanetFopts opts, int32_t argn, const Janet *argv) {
        JanetCompiler *c = opts.compiler;
        Janet head;
        opts.flags &= ~JANET_FOPTS_HINT;
        JanetTable *attr_table = handleattr(c, argn, argv);
        JanetSlot ret = dohead(c, opts, &head, argn, argv);
        if (c->result.status == JANET_COMPILE_ERROR)
            return janetc_cslot(janet_wrap_nil());
        destructure(c, argv[0], ret, defleaf, attr_table);
        return ret;
    }
    ``)

  (peg/match c-grammar static-src-2)
  # =>
  '@[(:paren 77 76) (:curly 1 450)]

  (def janet-core-def-src
    ``
    JANET_CORE_DEF(env, "math/pi", janet_wrap_number(3.1415926535897931),
                   "The value pi.");
    ``)

  (peg/match c-grammar janet-core-def-src)
  # =>
  '@[(:paren 31 100) (:semi-colon 32 101)]

  (def janet-quick-asm-src
    ``
    janet_quick_asm(env, JANET_FUN_BNOT,
                    "bnot", 1, 1, 1, 1, bnot_asm, sizeof(bnot_asm),
                    JDOC("(bnot x)\n\nReturns the bit-wise inverse of integer x."));
    ``)

  (peg/match c-grammar janet-quick-asm-src)
  # =>
  '@[(:paren 79 179) (:semi-colon 80 180)]

  (def janet-def-src
    ``
     janet_def(env, "janet/version", janet_cstringv(JANET_VERSION),
           JDOC("The version number of the running janet program."));
    ``)

  (peg/match c-grammar janet-def-src)
  # =>
  '@[(:paren 64 127) (:semi-colon 65 128)]

  (def templatize-comparator-src
    ``
    templatize_comparator(env, JANET_FUN_LT, "<", 0, JOP_LESS_THAN,
                          JDOC("(< & xs)\n\n"
                               "Check if ... order. Returns a boolean."));
    ``)

  (peg/match c-grammar templatize-comparator-src)
  # =>
  '@[(:paren 69 174) (:semi-colon 70 175)]

  (def templatize-varop-src
    ``
    templatize_varop(env, JANET_FUN_RSHIFT, "brshift", 1, 1, JOP_SHIFT_RIGHT,
                     JDOC("(brshift x & shifts)\n\n"
                          "Returns ... bit shifted right ... shifts. x ..."));
    ``)

  (peg/match c-grammar templatize-varop-src)
  # =>
  '@[(:paren 73 195) (:semi-colon 74 196)]

  (def janet-abstract-type-src
    ``
    const JanetAbstractType janet_peg_type = {
        "core/peg",
        NULL,
        peg_mark,
        cfun_peg_getter,
        NULL, /* put */
        peg_marshal,
        peg_unmarshal,
        NULL, /* tostring */
        NULL, /* compare */
        NULL, /* hash */
        peg_next,
        JANET_ATEND_NEXT
    };
    ``)

  (peg/match c-grammar janet-abstract-type-src)
  # =>
  '@[(:curly 1 265) (:semi-colon 2 266)]

  )

# adapted from index-janet's index-c.janet
(def col-one-mod
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
    # order of cmt swapped in this version of col-one
    :macro-define
    (choice
      (cmt (sequence (line) (column) (position)
                     # for displaying definitions, capture whole thing
                     (capture (sequence "#define" (thru `\`) "\n"
                                        (some (sequence
                                                # XXX: hoping no escapes
                                                (some (if-not (set "\n\\") 1))
                                                `\` "\n"))
                                        (thru "\n"))))
           ,|@{:bl $0
               :bc $1
               :bp $2
               :text $3})
      (cmt (sequence (line) (column) (position)
                     (capture (sequence "#define" (to "\n")))
                     "\n")
           ,|@{:bl $0
               :bc $1
               :bp $2
               :text $3}))
    :not-match 1})
