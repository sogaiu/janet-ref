(import ../index-janet/janet-query :as jq)

(comment

  (def query-str
    `(def <::name :blob> <:...>)`)

  (def src-str
    ``
    (def a 1)

    (defn b
      [x y]
      (def c [2 3]))

    (b)

    (def x :a)
    ``)

  (def [results _ loc->node]
    (jq/query query-str src-str {:blank-delims [`<` `>`]}))

  (length results)
  # =>
  3

  (length loc->node)
  # =>
  33

  results
  # =>
  '@[@{::name (:blob @{:bc 6 :bl 1 :bp 5
                       :ec 7 :el 1 :ep 6} "a")}
     @{::name (:blob @{:bc 8 :bl 5 :bp 34
                       :ec 9 :el 5 :ep 35} "c")}
     @{::name (:blob @{:bc 6 :bl 9 :bp 55
                       :ec 7 :el 9 :ep 56} "x")}]

  (get loc->node {:bc 6 :bl 9 :bp 55
                  :ec 7 :el 9 :ep 56})
  # =>
  '(:blob @{:bc 6 :bl 9 :bp 55
            :ec 7 :el 9 :ep 56}
          "x")

  )

(comment

  (def query-str
    `(defn <::name :blob> <:...>)`)

  (def src-str
    ``
    (def a 1)

    (defn b
      [x y]
      (def c [2 3]))

    (b)

    (def x :a)
    ``)

  (def [results _ loc->node]
    (jq/query query-str src-str {:blank-delims [`<` `>`]}))

  (length results)
  # =>
  1

  (length loc->node)
  # =>
  39

  results
  # =>
  '@[@{::name (:blob @{:bc 7 :bl 3 :bp 17
                       :ec 8 :el 3 :ep 18}
                     "b")}]

  (get loc->node {:bc 7 :bl 3 :bp 17
                  :ec 8 :el 3 :ep 18})
  # =>
  '(:blob @{:bc 7 :bl 3 :bp 17
            :ec 8 :el 3 :ep 18}
          "b")

  )

(comment

  (def query-str
    `(defn <::name :input> <:...>)`)

  (def src-str
    ``
    (compwhen (dyn 'net/listen)
      (defn net/server
        "Start a server asynchronously with `net/listen` and `net/accept-loop`. Returns the new server stream."
        [host port &opt handler type]
        (def s (net/listen host port type))
        (if handler
          (ev/call (fn [] (net/accept-loop s handler))))
        s))

    ``)

  (def [results _ loc->node]
    (jq/query query-str src-str {:blank-delims [`<` `>`]}))

  (length results)
  # =>
  1

  (length loc->node)
  # =>
  68

  results
  # =>
  '@[@{::name (:blob @{:bc 9 :bl 2 :bp 36
                       :ec 19 :el 2 :ep 46}
                     "net/server")}]

  (get loc->node {:bc 9 :bl 2 :bp 36
                  :ec 19 :el 2 :ep 46})
  # =>
  '(:blob @{:bc 9 :bl 2 :bp 36
            :ec 19 :el 2 :ep 46}
          "net/server")

  )

(comment

  (def query-str
    `(<::deftype '[capture [sequence "def" [to " "]]]>
      <::name :blob>
      <:...>)`)

  (def src-str
    ``
    (compwhen (dyn 'ffi/native)

      (defdyn *ffi-context* " Current native library for ffi/bind and other settings")

      (defn- default-mangle
        [name &]
        (string/replace-all "-" "_" name))

      (defn ffi/context
        "Set the path of the dynamic library to implictly bind, as well
         as other global state for ease of creating native bindings."
        [&opt native-path &named map-symbols lazy]
        (default map-symbols default-mangle)
        (def lib (if lazy nil (ffi/native native-path)))
        (def lazy-lib (if lazy (delay (ffi/native native-path))))
        (setdyn *ffi-context*
                @{:native-path native-path
                  :native lib
                  :native-lazy lazy-lib
                  :lazy lazy
                  :map-symbols map-symbols}))

      (defmacro ffi/defbind
        "Generate bindings for native functions in a convenient manner."
        [name ret-type & body]
        (def real-ret-type (eval ret-type))
        (def meta (slice body 0 -2))
        (def arg-pairs (partition 2 (last body)))
        (def formal-args (map 0 arg-pairs))
        (def type-args (map 1 arg-pairs))
        (def computed-type-args (eval ~[,;type-args]))
        (def {:native lib
              :lazy lazy
              :native-lazy llib
              :map-symbols ms} (assert (dyn *ffi-context*) "no ffi context found"))
        (def raw-symbol (ms name))
        (defn make-sig []
          (ffi/signature :default real-ret-type ;computed-type-args))
        (defn make-ptr []
          (assert (ffi/lookup (if lazy (llib) lib) raw-symbol) (string "failed to find ffi symbol " raw-symbol)))
        (if lazy
            ~(defn ,name ,;meta [,;formal-args]
               (,ffi/call (,(delay (make-ptr))) (,(delay (make-sig))) ,;formal-args))
            ~(defn ,name ,;meta [,;formal-args]
               (,ffi/call ,(make-ptr) ,(make-sig) ,;formal-args)))))

    ``)

  (def [results _ loc->node]
    (jq/query query-str src-str {:blank-delims [`<` `>`]}))

  (length results)
  # =>
  18

  (length loc->node)
  # =>
  334

  (seq [[_ v]:pairs results
        :let [name (get v ::name)]]
    name)
  # =>
  '@[(:blob @{:bc 11 :bl 3 :bp 39 :ec 24 :el 3 :ep 52}
            "*ffi-context*")
     (:blob @{:bc 10 :bl 5 :bp 122 :ec 24 :el 5 :ep 136}
            "default-mangle")
     (:blob @{:bc 14 :bl 13 :bp 404 :ec 25 :el 13 :ep 415}
            "map-symbols")
     (:blob @{:bc 10 :bl 14 :bp 441 :ec 13 :el 14 :ep 444}
            "lib")
     (:blob @{:bc 10 :bl 15 :bp 494 :ec 18 :el 15 :ep 502}
            "lazy-lib")
     (:blob @{:bc 9 :bl 9 :bp 198 :ec 20 :el 9 :ep 209}
            "ffi/context")
     (:blob @{:bc 10 :bl 26 :bp 871 :ec 23 :el 26 :ep 884}
            "real-ret-type")
     (:blob @{:bc 10 :bl 27 :bp 911 :ec 14 :el 27 :ep 915}
            "meta")
     (:blob @{:bc 10 :bl 28 :bp 944 :ec 19 :el 28 :ep 953}
            "arg-pairs")
     (:blob @{:bc 10 :bl 29 :bp 990 :ec 21 :el 29 :ep 1001}
            "formal-args")
     (:blob @{:bc 10 :bl 30 :bp 1030 :ec 19 :el 30 :ep 1039}
            "type-args")
     (:blob @{:bc 10 :bl 31 :bp 1068 :ec 28 :el 31 :ep 1086}
            "computed-type-args")
     (:blob @{:bc 10 :bl 36 :bp 1270 :ec 20 :el 36 :ep 1280}
            "raw-symbol")
     (:blob @{:bc 11 :bl 37 :bp 1302 :ec 19 :el 37 :ep 1310}
            "make-sig")
     (:blob @{:bc 11 :bl 39 :bp 1390 :ec 19 :el 39 :ep 1398}
            "make-ptr")
     (:blob @{:bc 16 :bl 42 :bp 1540 :ec 21 :el 42 :ep 1545}
            ",name")
     (:blob @{:bc 16 :bl 44 :bp 1666 :ec 21 :el 44 :ep 1671}
            ",name")
     (:blob @{:bc 13 :bl 23 :bp 754 :ec 24 :el 23 :ep 765}
            "ffi/defbind")]

  )



