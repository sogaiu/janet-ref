(import ../index-janet/c-query :as cq)

(comment

  (def src-str
    ``
    #define JANET_DEFINE_MATHOP(fop, doc) JANET_DEFINE_NAMED_MATHOP(#fop, fop, doc)

    JANET_DEFINE_MATHOP(acos, "Returns the arccosine of x.")
    JANET_DEFINE_MATHOP(asin, "Returns the arcsin of x.")
    JANET_DEFINE_MATHOP(atan, "Returns the arctangent of x.")
    ``)

  (def query-str
    ``
    JANET_DEFINE_MATHOP(<::name '(capture {:main (to ",")})>, <:str/dq>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name "acos"}
     @{::name "asin"}
     @{::name "atan"}]

  (def query-str
    ``
    JANET_DEFINE_MATHOP(<::name '(capture (to ","))>, <:...>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name "fop"}
     @{::name "acos"}
     @{::name "asin"}
     @{::name "atan"}]

  (def query-str
    ``
    JANET_DEFINE_MATHOP(<::name '[capture [to ","]]>, <:...>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name "fop"}
     @{::name "acos"}
     @{::name "asin"}
     @{::name "atan"}]

  (def query-str
    ``
    JANET_DEFINE_MATHOP(<::name '{:main (capture (to ","))}>, <:str/dq>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name "acos"}
     @{::name "asin"}
     @{::name "atan"}]

  # this used to cause an issue
  (def src-str
    ``
    #define JANET_DEFINE_NAMED_MATHOP(janet_name, fop, doc)\
    JANET_CORE_FN(janet_##fop, "(math/" janet_name " x)", doc) {\
        janet_fixarity(argc, 1); \
        double x = janet_getnumber(argv, 0); \
        return janet_wrap_number(fop(x)); \
    }

    #define JANET_DEFINE_MATHOP(fop, doc) JANET_DEFINE_NAMED_MATHOP(#fop, fop, doc)

    JANET_DEFINE_MATHOP(acos, "Returns the arccosine of x.")
    JANET_DEFINE_MATHOP(asin, "Returns the arcsin of x.")
    JANET_DEFINE_MATHOP(atan, "Returns the arctangent of x.")
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name "acos"}
     @{::name "asin"}
     @{::name "atan"}]

  (def query-str
    ``
    JANET_DEFINE_MATHOP(<::name '(capture {:main (to ",")})>, <:str/dq>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name "acos"}
     @{::name "asin"}
     @{::name "atan"}]

  (def query-str
    ``
    JANET_DEFINE_MATHOP(<::name '(group (sequence (capture (to ",")) (line)))>,
                        <:str/dq>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name @["acos" 10]}
     @{::name @["asin" 11]}
     @{::name @["atan" 12]}]

  (def query-str
    ``
    JANET_DEFINE_MATHOP(<::content :input> <:...>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::content (:blob @{:bc 29 :bl 8 :bp 264
                          :ec 33 :el 8 :ep 268} "fop,")}
     @{::content (:blob @{:bc 21 :bl 10 :bp 337
                          :ec 26 :el 10 :ep 342} "acos,")}
     @{::content (:blob @{:bc 21 :bl 11 :bp 394
                          :ec 26 :el 11 :ep 399} "asin,")}
     @{::content (:blob @{:bc 21 :bl 12 :bp 448
                          :ec 26 :el 12 :ep 453} "atan,")}]

  (def query-str
    ``
    JANET_DEFINE_MATHOP(<::pos '(line)><:...>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::pos 8}
     @{::pos 10}
     @{::pos 11}
     @{::pos 12}]

  (def query-str
    ``
    JANET_DEFINE_MATHOP(<:...>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  @[]

  )

(comment

  (def src-str
    ``
    #define JANET_DEFINE_NAMED_MATHOP(janet_name, fop, doc)\
    JANET_CORE_FN(janet_##fop, "(math/" janet_name " x)", doc) {\
        janet_fixarity(argc, 1); \
        double x = janet_getnumber(argv, 0); \
        return janet_wrap_number(fop(x)); \
    }
    ``)

  (def query-str
    ``
    <::thing :blob>(<:...>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::thing (:blob @{:bc 9 :bl 1 :bp 8 :ec 34 :el 1 :ep 33}
                      "JANET_DEFINE_NAMED_MATHOP")}
     @{::thing (:blob @{:bc 1 :bl 2 :bp 57 :ec 14 :el 2 :ep 70}
                      "JANET_CORE_FN")}
     @{::thing (:blob @{:bc 5 :bl 3 :bp 123 :ec 19 :el 3 :ep 137}
                     "janet_fixarity")}
     @{::thing (:blob @{:bc 16 :bl 4 :bp 165 :ec 31 :el 4 :ep 180}
                     "janet_getnumber")}
     @{::thing (:blob @{:bc 30 :bl 5 :bp 222 :ec 33 :el 5 :ep 225}
                      "fop")}
     @{::thing (:blob @{:bc 12 :bl 5 :bp 204 :ec 29 :el 5 :ep 221}
                      "janet_wrap_number")}]

  (map (fn [dict]
         (get-in dict [::thing 2]))
       results)
  # =>
  '@["JANET_DEFINE_NAMED_MATHOP"
     "JANET_CORE_FN"
     "janet_fixarity"
     "janet_getnumber"
     "fop"
     "janet_wrap_number"]

  (length loc->node)
  # =>
  60

  (def starts-with-janet-caps @[])

  (each val (values loc->node)
    (def [_ _ target] val)
    (when (and (string? target)
               (string/find "JANET" target))
      (array/push starts-with-janet-caps val)))

  starts-with-janet-caps
  # =>
  '@[(:blob @{:bc 9 :bl 1 :bp 8 :ec 34 :el 1 :ep 33}
            "JANET_DEFINE_NAMED_MATHOP")
     (:blob @{:bc 1 :bl 2 :bp 57 :ec 14 :el 2 :ep 70}
            "JANET_CORE_FN")]

  )

(comment

   (def src-str
     ``
     #define JANET_DEFINE_NAMED_MATHOP(janet_name, fop, doc)\
     JANET_CORE_FN(janet_##fop, "(math/" janet_name " x)", doc) {\
         janet_fixarity(argc, 1); \
         double x = janet_getnumber(argv, 0); \
         return janet_wrap_number(fop(x)); \
     }
     ``)

   (def query-str
     ``
     return <::value '(capture (to ";"))>;
     ``)

   (def [results _ loc->node]
     (cq/query query-str src-str {:blank-delims [`<` `>`]}))

   results
   # =>
   '@[@{::value "janet_wrap_number(fop(x))"}]

   (def query-str
     ``
     JANET_CORE_FN(<::content :input> <:...>)
     ``)

   (def [results _ loc->node]
     (cq/query query-str src-str {:blank-delims [`<` `>`]}))

   results
   # =>
   '@[@{::content
        (:blob @{:bc 15 :bl 2 :bp 71 :ec 27 :el 2 :ep 83} "janet_##fop,")}]

   (def query-str
     ``
     JANET_CORE_FN(<::content '(group (any :input))>)
     ``)

   (def [results _ loc->node]
     (cq/query query-str src-str {:blank-delims [`<` `>`]}))

   results
   # =>
   '@[@{::content
        @[(:blob @{:bc 15 :bl 2 :bp 71 :ec 27 :el 2 :ep 83} "janet_##fop,")
          (:ws/horiz @{:bc 27 :bl 2 :bp 83 :ec 28 :el 2 :ep 84} " ")
          (:str/dq @{:bc 28 :bl 2 :bp 84 :ec 36 :el 2 :ep 92} "\"(math/\"")
          (:ws/horiz @{:bc 36 :bl 2 :bp 92 :ec 37 :el 2 :ep 93} " ")
          (:blob @{:bc 37 :bl 2 :bp 93 :ec 47 :el 2 :ep 103} "janet_name")
          (:ws/horiz @{:bc 47 :bl 2 :bp 103 :ec 48 :el 2 :ep 104} " ")
          (:str/dq @{:bc 48 :bl 2 :bp 104 :ec 53 :el 2 :ep 109} "\" x)\"")
          (:blob @{:bc 53 :bl 2 :bp 109 :ec 54 :el 2 :ep 110} ",")
          (:ws/horiz @{:bc 54 :bl 2 :bp 110 :ec 55 :el 2 :ep 111} " ")
          (:blob @{:bc 55 :bl 2 :bp 111 :ec 58 :el 2 :ep 114} "doc")]}]

  )

(comment

  (def src-str
    ``

    JANET_DEFINE_MATHOP(erf, "Returns the error function of x.")
    JANET_DEFINE_MATHOP(erfc, "Returns the complementary error function of x.")
    JANET_DEFINE_NAMED_MATHOP("log-gamma", lgamma, "Returns log-gamma(x).")
    JANET_DEFINE_NAMED_MATHOP("abs", fabs, "Return the absolute value of x.")
    JANET_DEFINE_NAMED_MATHOP("gamma", tgamma, "Returns gamma(x).")

    #define JANET_DEFINE_MATH2OP(name, fop, signature, doc)\
    JANET_CORE_FN(janet_##name, signature, doc) {\
        janet_fixarity(argc, 2); \
        double lhs = janet_getnumber(argv, 0); \
        double rhs = janet_getnumber(argv, 1); \
        return janet_wrap_number(fop(lhs, rhs)); \
    }

    JANET_DEFINE_MATH2OP(atan2, atan2, "(math/atan2 y x)", "Returns the arctangent of y/x. Works even when x is 0.")
    JANET_DEFINE_MATH2OP(pow, pow, "(math/pow a x)", "Returns a to the power of x.")
    JANET_DEFINE_MATH2OP(hypot, hypot, "(math/hypot a b)", "Returns c from the equation c^2 = a^2 + b^2.")
    JANET_DEFINE_MATH2OP(nextafter, nextafter,  "(math/next x y)", "Returns the next representable floating point value after x in the direction of y.")
    ``)

  (def query-str
    ``
    <'(sequence "JANET_DEFINE_"
                (choice "NAMED_" "")
                "MATHOP")>(<::name '(capture (to ","))>,
     <:...>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name "erf"}
     @{::name "erfc"}
     @{::name "\"log-gamma\""}
     @{::name "\"abs\""}
     @{::name "\"gamma\""}]

  # seems to work -- not so easy to read?
  (def query-str
    ``
    <'(sequence
        (choice "JANET_DEFINE_NAMED_MATHOP"
                "JANET_DEFINE_MATH2OP"
                "JANET_DEFINE_MATHOP"))>(<'(choice
                                             (sequence :str/dq "," :ws)
                                             "")><::name '(capture (to ","))>,
                                         <:str/dq>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name "erf"}
     @{::name "erfc"}
     @{::name "lgamma"}
     @{::name "fabs"}
     @{::name "tgamma"}]

  (def query-str
    ``
    <'(sequence (choice "JANET_DEFINE_NAMED_MATHOP"
                        "JANET_DEFINE_MATH2OP"
                        "JANET_DEFINE_MATHOP"))
    >(<'(choice (sequence :str/dq "," :ws)
                "")
    ><::name '(capture (to ","))>,
    <:str/dq>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name "erf"}
     @{::name "erfc"}
     @{::name "lgamma"}
     @{::name "fabs"}
     @{::name "tgamma"}]

  (def query-str
    ``
    <'(sequence (look -1 "\n")
                (choice "JANET_DEFINE_NAMED_MATHOP"
                        "JANET_DEFINE_MATH2OP"
                        "JANET_DEFINE_MATHOP"))
    >(<::name ~(cmt (capture (to ","))
                   ,(fn [cap]
                      (if (string/has-prefix? `"` cap)
                        (string/slice cap 1 -2)
                        cap)))>,
    <:...>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name "erf"}
     @{::name "erfc"}
     @{::name "log-gamma"}
     @{::name "abs"}
     @{::name "gamma"}
     @{::name "atan2"}
     @{::name "pow"}
     @{::name "hypot"}
     @{::name "nextafter"}]

  (def query-str
    ``
    <'(sequence (choice "JANET_DEFINE_NAMED_MATHOP"
                        "JANET_DEFINE_MATH2OP"
                        "JANET_DEFINE_MATHOP"))
    >(<'(choice (sequence :str/dq "," :ws)
                "")
    ><::name '(group (sequence (line)
                              (position)
                              (capture (to ","))))>,
    <:str/dq>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name @[2 21 "erf"]}
     @{::name @[3 82 "erfc"]}
     @{::name @[4 177 "lgamma"]}
     @{::name @[5 243 "fabs"]}
     @{::name @[6 319 "tgamma"]}]

  (def query-str
    ``
    <'[sequence [choice "JANET_DEFINE_NAMED_MATHOP"
                        "JANET_DEFINE_MATH2OP"
                        "JANET_DEFINE_MATHOP"]]
    >(<'[choice [sequence :str/dq "," :ws]
                ""]
    ><::name '[group [sequence [line]
                               [position]
                               [capture [to ","]]]]>,
    <:str/dq>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name @[2 21 "erf"]}
     @{::name @[3 82 "erfc"]}
     @{::name @[4 177 "lgamma"]}
     @{::name @[5 243 "fabs"]}
     @{::name @[6 319 "tgamma"]}]

  (def query-str
    ``
    <'(sequence (look -1 "\n")
                (choice "JANET_DEFINE_NAMED_MATHOP"
                        "JANET_DEFINE_MATH2OP"
                        "JANET_DEFINE_MATHOP"))
    >(<::name ~(cmt (capture (to ","))
                   ,(fn [cap]
                      (if (string/has-prefix? `"` cap)
                        (string/slice cap 1 -2)
                        cap)))>,
    <:...>)
    ``)

  (def [results _ loc->node]
    (cq/query query-str src-str {:blank-delims [`<` `>`]}))

  results
  # =>
  '@[@{::name "erf"}
     @{::name "erfc"}
     @{::name "log-gamma"}
     @{::name "abs"}
     @{::name "gamma"}
     @{::name "atan2"}
     @{::name "pow"}
     @{::name "hypot"}
     @{::name "nextafter"}]

  )

(comment

  (def src-str
    ``
    #define JANET_DEFINE_NAMED_MATHOP(janet_name, fop, doc)\
    JANET_CORE_FN(janet_##fop, "(math/" janet_name " x)", doc) {\
        janet_fixarity(argc, 1); \
        double x = janet_getnumber(argv, 0); \
        return janet_wrap_number(fop(x)); \
    }
    ``)

  (def {:lang-grammar l-grammar
        :loc-table loc->node
        :parse-query parse-query
        :query-grammar q-grammar}
    (cq/make-infra {:safe-delim "$"}))

  (peg/match l-grammar src-str)

  # used to show clash between line continuation and blank
  (parse-query src-str)

  )

