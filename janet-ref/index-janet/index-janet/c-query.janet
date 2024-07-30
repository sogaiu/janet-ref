(import ./loc :as l)
(import ./c-peg :as cp)
(import ./debug :as d)

# options should be a dictionary with things such as:
#
# * blank delimiter safe character info
#   * single delim for both sides
#   * left delim diff from right delim
#   * open-delim / close-delim fixed chars?
#   * raw-string like delimiting?
# * string escape character info
# * blob character info
# * possibly other things eventually
#   * line comment info
#   * multi-line comment info
#   * whitespace info
#   * raw string info
#
# XXX: could "lint" the options, e.g. conflict in blob char with
#      blank delims
(defn make-infra
  [&opt opts]

  (def safe-delim
    (if-let [bd (get opts :safe-delim)]
      bd
      `$`))

  (def loc->node @{})

  (def n-safe-delims @[])

  (defn opaque-node
    [the-type peg-form]
    ~(cmt (capture (sequence (line) (column) (position)
                             ,peg-form
                             (line) (column) (position)))
          # XXX: ;(tuple/slice $& 0 -2) might work here
          ,|(let [attrs (l/make-attrs ;(tuple/slice $& 0 3)
                                      ;(tuple/slice $& (- (- 3) 2) -2))
                  node [the-type attrs (last $&)]]
              (put loc->node (freeze attrs) node)
              node)))

  (defn delim-node
    [the-type open close]
    ~(cmt
       (capture
         (sequence
           (line) (column) (position)
           ,open
           (any :input)
           (choice ,close
                   (error
                     (replace (sequence (line) (column) (position))
                              ,|(string/format
                                  (string "line: %d column: %d pos: %d "
                                          "missing %s for %s")
                                  $0 $1 $2 close the-type))))
           (line) (column) (position)))
       ,|(let [attrs (l/make-attrs ;(tuple/slice $& 0 3)
                                   ;(tuple/slice $& (- (- 3) 2) -2))
               node [the-type attrs ;(tuple/slice $& 3 (- (- 3 ) 2))]]
           (put loc->node (freeze attrs) node)
           node)))

  (def lang-grammar
    (cp/make-grammar {:opaque-node opaque-node
                      :delim-node delim-node}))

  (def query-grammar
    (-> (struct/to-table lang-grammar)
        (put
          :form (let [old-form (get lang-grammar :form)]
                  (tuple 'choice
                         :blank
                         ;(tuple/slice old-form 1))))
        (put :... '(any :input))
        (put
          :blank
          ~(cmt (capture
                  (sequence (line) (column) (position)
                            (capture :blank-internal)
                            (line) (column) (position)))
                ,|(let [attrs (l/make-attrs ;(tuple/slice $& 0 3)
                                            ;(tuple/slice $& (- (- 3) 2) -2))
                        n (array/pop n-safe-delims)
                        [value] (slice $& 3 (- (- 3) 2))]
                    # XXX
                    (d/deprintf "$&: %n" $&)
                    (d/deprintf "attrs: %n" attrs)
                    (d/deprintf "value: %n" value)
                    (d/deprintf "n: %d" n)
                    # discard the surrounding blank delimiters
                    [:blank attrs (string/slice value n (dec (- n)))])))
        (put
          :blank-internal
          ~{:main (drop (sequence :open
                                  (any (if-not :close 1))
                                  :close))
            :open (capture :delim :n)
            # use "safe" delimiters, e.g. $, if possible?
            :delim (some ,safe-delim)
            :close (cmt (sequence (not (look -1 ,safe-delim))
                                  (backref :n)
                                  (capture (backmatch :n)))
                        ,(fn [left right]
                           (when (= left right)
                             # hack to pass back number of safe-delims
                             (array/push n-safe-delims
                                         (length left))
                             true)))})))
  #
  (defn parse-query
    [src &opt start single]
    (default start 0)
    (def top-level-ast
      (let [tla (table ;(kvs query-grammar))]
        (put tla
             :main ~(sequence (line) (column) (position)
                              :input
                              (line) (column) (position)))
        (table/to-struct tla)))
    #
    (def top-node
      (if single
        (if-let [[bl bc bp tree el ec ep]
                 (peg/match top-level-ast src start)]
          @[:code (l/make-attrs bl bc bp el ec ep) tree]
          @[:code])
        (if-let [captures (peg/match query-grammar src start)]
          (let [[bl bc bp] (slice captures 0 3)
                [el ec ep] (slice captures (dec -3))
                trees (array/slice captures 3 (dec -3))]
            (array/insert trees 0
                          :code (l/make-attrs bl bc bp el ec ep)))
          @[:code])))
    #
    top-node)
  # must start with ::
  (defn blank-sym-name?
    [cand]
    (peg/match
      '(sequence "::"
                 (some (choice (range "09" "AZ" "az" "\x80\xFF")
                               (set "!$%&*+-./:<?=>@^_")))
                 -1)
      cand))

  (defn parse-blank-data
    [blank-data]
    # special name meaning to match (but don't capture) 0 or more :input
    (when (= ":..." blank-data)
      (break [~(drop ,(get query-grammar :...))]))
    #
    (def parse-results (parse-all blank-data))
    (def n-results (length parse-results))
    (assert (pos? n-results)
            (string/format "Failed to parse: %n" blank-data))
    (def [head neck] parse-results)
    #
    (case n-results
      1
      (cond
        # only ~ something and ' something
        (and (tuple? head)
             (or (= 'quasiquote (first head))
                 (= 'quote (first head))))
        # drop is here to ensure no captures happen
        [~(drop ,(eval head))]
        #
        (or (number? head) (string? head))
        # numbers and strings cannot capture so no drop needed
        [head]
        # keyword from grammar means to match
        (and (keyword? head)
             (get lang-grammar head))
        [~(drop ,head)]
        #
        (errorf "Unrecognized first item: %n in blank-data: %n"
                head blank-data))
      2
      (do
        (assert (and (keyword? head)
                     (blank-sym-name? (string ":" head)))
                (string/format "Not a valid blank name: %s in blank-data: %s"
                               head blank-data))
        (def the-capture
          (cond
            # only ~ something and ' something
            (and (tuple? neck)
                 (or (= 'quasiquote (first neck))
                     (= 'quote (first neck))))
            (eval neck)
            #
            (or (number? neck) (string? neck))
            (errorf "numbers and strings don't capture: %n" neck)
            #
            (keyword? neck)
            (if (get lang-grammar neck)
              neck
              (errorf "Keyword %n not in grammar" neck))
            #
            (errorf "Unrecognized second item: %n in blank-data: %n"
                    neck blank-data)))
        [(tuple 'constant head)
         the-capture])
      #
      (errorf "Too many items, should only be 1 or 2: %n"
              (length parse-results))))
  #
  (defn make-query-peg
    [an-ast arr]
    (var saw-ws-last-time nil)
    (defn gen*
      [an-ast arr]
      (def head (first an-ast))
      (when (and (or (not= :ws/eol head)
                     (not= :ws/horiz head))
                 saw-ws-last-time)
        (set saw-ws-last-time false))
      (case head
        :code
        (each elt (drop 2 an-ast)
          (gen* elt arr))
        #
        :blob
        (array/push arr (in an-ast 2))
        :cmt/line
        (array/push arr (in an-ast 2))
        :cmt/m-line
        (array/push arr (in an-ast 2))
        :str/dq
        (array/push arr (in an-ast 2))
        :str/sq
        (array/push arr (in an-ast 2))
        :ws/eol
        (when (not saw-ws-last-time)
          (set saw-ws-last-time true)
          (array/push arr :s+))
        :ws/horiz
        (when (not saw-ws-last-time)
          (set saw-ws-last-time true)
          (array/push arr :s+))
        #
        :blank
        (array/concat arr (parse-blank-data (in an-ast 2)))
        #
        :dl/square
        (do
          (array/push arr "[")
          (each elt (drop 2 an-ast)
            (gen* elt arr))
          (array/push arr "]"))
        :dl/round
        (do
          (array/push arr "(")
          (each elt (drop 2 an-ast)
            (gen* elt arr))
          (array/push arr ")"))
        :dl/curly
        (do
          (array/push arr "{")
          (each elt (drop 2 an-ast)
            (gen* elt arr))
          (array/push arr "}"))
        )
      #
      arr)
    #
    (gen* an-ast arr))
  #
  {:lang-grammar lang-grammar
   :loc-table loc->node
   :parse-query parse-query
   :query-grammar query-grammar
   :make-query-peg make-query-peg
   :parse-blank-data parse-blank-data})

(comment

  (def {:lang-grammar l-grammar
        :query-grammar q-grammar
        :parse-query parse-query}
    (make-infra {:safe-delim "$"}))

  (get (peg/match l-grammar `2`) 3)
  # =>
  '(:blob @{:bc 1 :bl 1 :bp 0 :ec 2 :el 1 :ep 1} "2")

  (array/slice (peg/match q-grammar `$a$ + 2`)
               3 (dec (- 3)))
  # =>
  '@[(:blank @{:bc 1 :bl 1 :bp 0 :ec 4 :el 1 :ep 3} "a")
     (:ws/horiz @{:bc 4 :bl 1 :bp 3 :ec 5 :el 1 :ep 4} " ")
     (:blob @{:bc 5 :bl 1 :bp 4 :ec 6 :el 1 :ep 5} "+")
     (:ws/horiz @{:bc 6 :bl 1 :bp 5 :ec 7 :el 1 :ep 6} " ")
     (:blob @{:bc 7 :bl 1 :bp 6 :ec 8 :el 1 :ep 7} "2")]

  (parse-query `$a$ + 2`)
  # =>
  '@[:code @{:bc 1 :bl 1 :bp 0 :ec 8 :el 1 :ep 7}
     (:blank @{:bc 1 :bl 1 :bp 0 :ec 4 :el 1 :ep 3} "a")
     (:ws/horiz @{:bc 4 :bl 1 :bp 3 :ec 5 :el 1 :ep 4} " ")
     (:blob @{:bc 5 :bl 1 :bp 4 :ec 6 :el 1 :ep 5} "+")
     (:ws/horiz @{:bc 6 :bl 1 :bp 5 :ec 7 :el 1 :ep 6} " ")
     (:blob @{:bc 7 :bl 1 :bp 6 :ec 8 :el 1 :ep 7} "2")]

  (parse-query
    ``
    janet_def($...$ "janet/version", $...$);
    ``)
  # =>
  '@[:code @{:bc 1 :bl 1 :bp 0 :ec 41 :el 1 :ep 40}
     (:blob @{:bc 1 :bl 1 :bp 0 :ec 10 :el 1 :ep 9} "janet_def")
     (:dl/round @{:bc 10 :bl 1 :bp 9 :ec 40 :el 1 :ep 39}
                (:blank @{:bc 11 :bl 1 :bp 10 :ec 16 :el 1 :ep 15} "...")
                (:ws/horiz @{:bc 16 :bl 1 :bp 15 :ec 17 :el 1 :ep 16} " ")
                (:str/dq @{:bc 17 :bl 1 :bp 16 :ec 32 :el 1 :ep 31}
                         "\"janet/version\"")
                (:blob @{:bc 32 :bl 1 :bp 31 :ec 33 :el 1 :ep 32} ",")
                (:ws/horiz @{:bc 33 :bl 1 :bp 32 :ec 34 :el 1 :ep 33} " ")
                (:blank @{:bc 34 :bl 1 :bp 33 :ec 39 :el 1 :ep 38} "..."))
     (:blob @{:bc 40 :bl 1 :bp 39 :ec 41 :el 1 :ep 40} ";")]

  )

(comment

  (def {:parse-blank-data parse-blank-data}
    (make-infra {:safe-delim "$"}))

  (parse-blank-data `:...`)
  # =>
  '[(drop (any :input))]

  (parse-blank-data `'(sequence (range "09") (to "\n"))`)
  # =>
  '[(drop (sequence (range "09") (to "\n")))]

  # '8 -macro-expand-> (quote 8) -eval-> 8
  (parse-blank-data `'8`)
  # =>
  '[(drop 8)]

  (parse-blank-data `12`)
  # =>
  [12]

  (parse-blank-data `"i am a string"`)
  # =>
  ["i am a string"]

  (parse-blank-data `::name ~2`)
  # =>
  '[(constant ::name) 2]

  (parse-blank-data `::name '1`)
  # =>
  '[(constant ::name) 1]

  (parse-blank-data `::name ''1`)
  # =>
  '[(constant ::name) (quote 1)]

  (try
    (parse-blank-data `::name 8`)
    ([e]
      (truthy? (string/find "don't capture" e))))
  # =>
  true

  (try
    (parse-blank-data `::name "fun string"`)
    ([e]
      (truthy? (string/find "don't capture" e))))
  # =>
  true

  (parse-blank-data `::name :form`)
  # =>
  '[(constant ::name) :form]

  (parse-blank-data `:form`)
  # =>
  '[(drop :form)]

  )

# the idea in the following function is to modify a grammar that
# produces a tree of nodes from a string that represents janet code,
# and use peg/match with this modified grammar to execute our query.
#
# instead of using the capture stack to capture the desired result, a
# separate "backstack" is used to collect desired targets as tables.
#
# the ordinary capture stack is not interfered with so it can be used
# in the ordinary fashion to produce the tree of nodes.  this makes
# getting at the desired results easier, but possibly it also doesn't
# mess up the capturing process (though not sure of this latter point).
(defn query
  [query-str src-str &opt opts]
  #
  (def [safe-left-delim safe-right-delim]
    ["$" "$"])
  #
  (def [blank-left blank-right]
    (if-let [[bl br] (get opts :blank-delims)]
      [bl br]
      [safe-left-delim safe-right-delim]))
  # XXX: does this help?  can anything else be done?
  (when (or (and (not= blank-left safe-left-delim)
                 (string/find safe-left-delim query-str))
            (and (not= blank-right safe-right-delim)
                 (string/find safe-right-delim query-str)))
    (eprintf ``
             query-str contains characters that should be avoided:

             query-str:

             %s

             left delim: %s
             right delim: %s
             ``
             query-str safe-left-delim safe-right-delim))
  #
  (def {:lang-grammar l-grammar
        :loc-table loc->node
        :parse-query parse-query
        :make-query-peg make-query-peg
        :query-grammar q-grammar}
    # XXX: only one delim?
    (make-infra {:safe-delim safe-left-delim}))
  # XXX
  (d/deprintf "query-str: %n" query-str)
  # XXX: does this handle all cases?
  (def safe-query-str
    (if-let [[left-delim right-delim] (get opts :blank-delims)]
      (->> query-str
           (string/replace-all left-delim safe-left-delim)
           (string/replace-all right-delim safe-right-delim))
      query-str))
  # XXX
  (d/deprintf "safe-query-str: %n" safe-query-str)
  (def query-tree
    (parse-query safe-query-str))
  # XXX
  (d/deprintf "query-tree: %n" query-tree)
  (def backstack @[])
  (def converted
    (make-query-peg query-tree @[]))
  # XXX
  (d/deprintf "converted: %n" converted)
  # merge successive :s+ to allow more readable queries
  (def massaged
    (reduce (fn [acc item]
              (if (and (= :s+ (last acc))
                       (= :s+ item))
                acc
                (array/push acc item)))
            @[]
            converted))
  # XXX
  (d/deprintf "massaged: %n" massaged)
  (def query-peg
    ~(cmt (sequence ,;massaged)
          ,(fn [& args]
             # XXX
             (if (empty? args)
               (d/deprint "args was empty")
               (d/deprintf "args: %n" args))
             # capture elsewhere, but only if non-empty args
             (when (not (empty? args))
               (array/push backstack (table ;args)))
             # pass-thru -- XXX: but does this really work?
             args)))
  # integrate the query-peg with the language grammar
  (def search-grammar
    (-> (struct/to-table l-grammar)
        (put :main ~(some :input))
        # add our query to the grammar
        (put :query query-peg)
        # make the query one of the items in the choice special for
        # :form so querying works on "interior" forms.  otherwise only
        # top-level captures show up.
        (put :form (let [old-form (get l-grammar :form)]
                     (tuple 'choice
                            :query
                            ;(tuple/slice old-form 1))))))
  # XXX: affects loc->node content
  #(d/deprintf "parsing src-str with l-grammar:\n\n%n"
  #              (peg/match l-grammar src-str))
  #
  [backstack
   (peg/match search-grammar src-str)
   loc->node])

(comment

  (def src-str
    ``
    janet_def(env, "janet/version", janet_cstringv(JANET_VERSION),
              JDOC("The version number of the running janet program."));
    ``)

  (def query-str
    `JDOC($::docstring :str/dq$)`)

  (def [results _ loc->node]
    (query query-str src-str))

  (def query-str
    `JDOC(<::docstring :str/dq>)`)

  (def [results _ loc->node]
    (query query-str src-str {:blank-delims [`<` `>`]}))

  (length results)
  # =>
  1

  (length loc->node)
  # =>
  17

  (first (keys loc->node))
  # =>
  {:bc 15 :bl 1 :bp 14 :ec 16 :el 1 :ep 15}

  (get loc->node {:bc 15 :bl 1 :bp 14 :ec 16 :el 1 :ep 15})
  # =>
  '(:ws/horiz @{:bc 15 :bl 1 :bp 14 :ec 16 :el 1 :ep 15} " ")

  results
  # =>
  '@[@{::docstring
       (:str/dq @{:bc 16 :bl 2 :bp 78 :ec 66 :el 2 :ep 128}
                "\"The version number of the running janet program.\"")}]

  (get loc->node {:bc 16 :bl 2 :bp 78 :ec 66 :el 2 :ep 128})
  # =>
  '(:str/dq @{:bc 16 :bl 2 :bp 78 :ec 66 :el 2 :ep 128}
            "\"The version number of the running janet program.\"")

  )

(comment

  (def query-str
    `argv[<::interior :form>]`)

  (def src-str
    ``
    static JanetSlot janetc_quote(JanetFopts opts, int32_t argn, const Janet *argv) {
        return janetc_cslot(argv[0]);
    }
    ``)

  (def [results _ loc->node]
    (query query-str src-str {:blank-delims [`<` `>`]}))

  (length results)
  # =>
  1

  (length loc->node)
  # =>
  32

  results
  # =>
  '@[@{::interior (:blob @{:bc 30 :bl 2 :bp 111
                           :ec 31 :el 2 :ep 112}
                         "0")}]

  (get loc->node {:bc 30 :bl 2 :bp 111
                  :ec 31 :el 2 :ep 112})
  # =>
  '(:blob @{:bc 30 :bl 2 :bp 111
            :ec 31 :el 2 :ep 112}
          "0")

  )

