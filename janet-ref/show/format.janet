# bl - begin line
# bc - begin column
# el - end line
# ec - end column
(defn make-attrs
  [& items]
  (zipcoll [:bl :bc :el :ec]
           items))

(defn atom-node
  [node-type peg-form]
  ~(cmt (capture (sequence (line) (column)
                           ,peg-form
                           (line) (column)))
        ,|[node-type (make-attrs ;(slice $& 0 -2)) (last $&)]))

(defn reader-macro-node
  [node-type sigil]
  ~(cmt (capture (sequence (line) (column)
                           ,sigil
                           (any :non-form)
                           :form
                           (line) (column)))
        ,|[node-type (make-attrs ;(slice $& 0 2) ;(slice $& -4 -2))
           ;(slice $& 2 -4)]))

(defn collection-node
  [node-type open-delim close-delim]
  ~(cmt
     (capture
       (sequence
         (line) (column)
         ,open-delim
         (any :input)
         (choice ,close-delim
                 (error
                   (replace (sequence (line) (column))
                            ,|(string/format
                                "line: %p column: %p missing %p for %p"
                                $0 $1 close-delim node-type))))
         (line) (column)))
     ,|[node-type (make-attrs ;(slice $& 0 2) ;(slice $& -4 -2))
        ;(slice $& 2 -4)]))

(def loc-grammar
  ~{:main (sequence (line) (column)
                    (some :input)
                    (line) (column))
    #
    :input (choice :non-form
                   :form)
    #
    :non-form (choice :whitespace
                      :comment)
    #
    :whitespace ,(atom-node :whitespace
                            '(choice (some (set " \0\f\t\v"))
                                     (choice "\r\n"
                                             "\r"
                                             "\n")))
    # :whitespace
    # (cmt (capture (sequence (line) (column)
    #                         (choice (some (set " \0\f\t\v"))
    #                                 (choice "\r\n"
    #                                         "\r"
    #                                         "\n"))
    #                         (line) (column)))
    #      ,|[:whitespace (make-attrs ;(slice $& 0 -2)) (last $&)])
    #
    :comment ,(atom-node :comment
                         '(sequence "#"
                                    (any (if-not (set "\r\n") 1))))
    #
    :form (choice :unreadable
                  # reader macros
                  :fn
                  :quasiquote
                  :quote
                  :splice
                  :unquote
                  # collections
                  :array
                  :bracket-array
                  :tuple
                  :bracket-tuple
                  :table
                  :struct
                  # atoms
                  :number
                  :constant
                  :buffer
                  :string
                  :long-buffer
                  :long-string
                  :keyword
                  :symbol)
    #
    :unreadable ,(atom-node :unreadable
                            '(sequence "<"
                                       (between 1 32 :name-char)
                                       :s+
                                       (thru ">")))
    #
    :fn ,(reader-macro-node :fn "|")
    # :fn (cmt (capture (sequence (line) (column)
    #                             "|"
    #                             (any :non-form)
    #                             :form
    #                             (line) (column)))
    #          ,|[:fn (make-attrs ;(slice $& 0 2) ;(slice $& -4 -2))
    #             ;(slice $& 2 -4)])
    #
    :quasiquote ,(reader-macro-node :quasiquote "~")
    #
    :quote ,(reader-macro-node :quote "'")
    #
    :splice ,(reader-macro-node :splice ";")
    #
    :unquote ,(reader-macro-node :unquote ",")
    #
    :array ,(collection-node :array "@(" ")")
    # :array
    # (cmt
    #   (capture
    #     (sequence
    #       (line) (column)
    #       "@("
    #       (any :input)
    #       (choice ")"
    #               (error
    #                 (replace (sequence (line) (column))
    #                          ,|(string/format
    #                              "line: %p column: %p missing %p for %p"
    #                              $0 $1 ")" :array))))
    #       (line) (column)))
    #   ,|[:array (make-attrs ;(slice $& 0 2) ;(slice $& -4 -2))
    #      ;(slice $& 2 -4)])
    #
    :tuple ,(collection-node :tuple "(" ")")
    #
    :bracket-array ,(collection-node :bracket-array "@[" "]")
    #
    :bracket-tuple ,(collection-node :bracket-tuple "[" "]")
    #
    :table ,(collection-node :table "@{" "}")
    #
    :struct ,(collection-node :struct "{" "}")
    #
    :number ,(atom-node :number
                        ~(drop (cmt
                                 (capture (some :name-char))
                                 ,scan-number)))
    #
    :name-char (choice (range "09" "AZ" "az" "\x80\xFF")
                       (set "!$%&*+-./:<?=>@^_"))
    #
    :constant ,(atom-node :constant
                          '(choice "false" "nil" "true"))
    #
    :buffer ,(atom-node :buffer
                        '(sequence `@"`
                                   (any (choice :escape
                                                (if-not "\"" 1)))
                                   `"`))
    #
    :escape (sequence "\\"
                      (choice (set "0efnrtvz\"\\")
                              (sequence "x" (2 :h))
                              (sequence "u" (4 :h))
                              (sequence "U" (6 :h))
                              (error (constant "bad escape"))))
    #
    :string ,(atom-node :string
                        '(sequence `"`
                                   (any (choice :escape
                                                (if-not "\"" 1)))
                                   `"`))
    #
    :long-string ,(atom-node :long-string
                             :long-bytes)
    #
    :long-bytes {:main (drop (sequence :open
                                       (any (if-not :close 1))
                                       :close))
                 :open (capture :delim :n)
                 :delim (some "`")
                 :close (cmt (sequence (not (look -1 "`"))
                                       (backref :n)
                                       (capture :delim))
                             ,=)}
    #
    :long-buffer ,(atom-node :long-buffer
                             '(sequence "@" :long-bytes))
    #
    :keyword ,(atom-node :keyword
                         '(sequence ":"
                                    (any :name-char)))
    #
    :symbol ,(atom-node :symbol
                        '(some :name-char))
    })

(comment

  (get (peg/match loc-grammar " ") 2)
  # =>
  '(:whitespace @{:bc 1 :bl 1 :ec 2 :el 1} " ")

  (get (peg/match loc-grammar "# hi there") 2)
  # =>
  '(:comment @{:bc 1 :bl 1 :ec 11 :el 1} "# hi there")

  (get (peg/match loc-grammar "8.3") 2)
  # =>
  '(:number @{:bc 1 :bl 1 :ec 4 :el 1} "8.3")

  (get (peg/match loc-grammar "printf") 2)
  # =>
  '(:symbol @{:bc 1 :bl 1 :ec 7 :el 1} "printf")

  (get (peg/match loc-grammar ":smile") 2)
  # =>
  '(:keyword @{:bc 1 :bl 1 :ec 7 :el 1} ":smile")

  (get (peg/match loc-grammar `"fun"`) 2)
  # =>
  '(:string @{:bc 1 :bl 1 :ec 6 :el 1} "\"fun\"")

  (get (peg/match loc-grammar "``long-fun``") 2)
  # =>
  '(:long-string @{:bc 1 :bl 1 :ec 13 :el 1} "``long-fun``")

  (get (peg/match loc-grammar "@``long-buffer-fun``") 2)
  # =>
  '(:long-buffer @{:bc 1 :bl 1 :ec 21 :el 1} "@``long-buffer-fun``")

  (get (peg/match loc-grammar `@"a buffer"`) 2)
  # =>
  '(:buffer @{:bc 1 :bl 1 :ec 12 :el 1} "@\"a buffer\"")

  (get (peg/match loc-grammar "@[8]") 2)
  # =>
  '(:bracket-array @{:bc 1 :bl 1
                     :ec 5 :el 1}
                   (:number @{:bc 3 :bl 1
                              :ec 4 :el 1} "8"))

  (get (peg/match loc-grammar "@{:a 1}") 2)
  # =>
  '(:table @{:bc 1 :bl 1
             :ec 8 :el 1}
           (:keyword @{:bc 3 :bl 1
                       :ec 5 :el 1} ":a")
           (:whitespace @{:bc 5 :bl 1
                          :ec 6 :el 1} " ")
           (:number @{:bc 6 :bl 1
                      :ec 7 :el 1} "1"))

  (get (peg/match loc-grammar "~x") 2)
  # =>
  '(:quasiquote @{:bc 1 :bl 1
                  :ec 3 :el 1}
                (:symbol @{:bc 2 :bl 1
                           :ec 3 :el 1} "x"))

  (get (peg/match loc-grammar "<core/peg 0xdeedabba>") 2)
  # =>
  '(:unreadable @{:bc 1 :bl 1 :ec 22 :el 1} "<core/peg 0xdeedabba>")

  )

(def loc-top-level-ast
  (let [ltla (table ;(kvs loc-grammar))]
    (put ltla
         :main ~(sequence (line) (column)
                          :input
                          (line) (column)))
    (table/to-struct ltla)))

(defn par
  [src &opt start single]
  (default start 0)
  (if single
    (if-let [[bl bc tree el ec]
             (peg/match loc-top-level-ast src start)]
      @[:code (make-attrs bl bc el ec) tree]
      @[:code])
    (if-let [captures (peg/match loc-grammar src start)]
      (let [[bl bc] (slice captures 0 2)
            [el ec] (slice captures -3)
            trees (array/slice captures 2 -3)]
        (array/insert trees 0
                      :code (make-attrs bl bc el ec)))
      @[:code])))

(comment

  (par "(+ 1 1)")
  # =>
  '@[:code @{:bc 1 :bl 1
             :ec 8 :el 1}
     (:tuple @{:bc 1 :bl 1
               :ec 8 :el 1}
             (:symbol @{:bc 2 :bl 1
                        :ec 3 :el 1} "+")
             (:whitespace @{:bc 3 :bl 1
                            :ec 4 :el 1} " ")
             (:number @{:bc 4 :bl 1
                        :ec 5 :el 1} "1")
             (:whitespace @{:bc 5 :bl 1
                            :ec 6 :el 1} " ")
             (:number @{:bc 6 :bl 1
                        :ec 7 :el 1} "1"))]

  )

(defn fmt
  [src]
  (def buf @"")
  (def an-ast (par src))
  (def indt-stack @[""])
  (var cur-col 0)
  #
  (defn fmt*
    [an-ast buf]
    (def the-type (first an-ast))
    (cond
      (= :code the-type)
      (each elt (drop 2 an-ast)
        (fmt* elt buf))
      #
      (get {:unreadable true
            #
            :whitespace true
            :comment true
            #
            :buffer true
            :constant true
            :keyword true
            :long-buffer true
            :long-string true
            :number true
            :string true
            :symbol true}
           the-type)
      (let [item (in an-ast 2)]
        (+= cur-col (length item))
        (buffer/push-string buf item))
      #
      (get {:array true
            :bracket-array true
            :bracket-tuple true
            :tuple true}
           the-type)
      (let [[open-delim close-delim]
            (case the-type
              :array ["@(" ")"]
              :bracket-array ["@[" "]"]
              :bracket-tuple ["[" "]"]
              :tuple ["(" ")"])
            items (filter |(and (not= :whitespace (first $))
                                (not= :comment (first $)))
                          (drop 2 an-ast))
            has-dict? (find |(or (= :struct (first $))
                                 (= :table (first $)))
                            items)]
        (+= cur-col (length open-delim))
        (buffer/push-string buf open-delim)
        (array/push indt-stack
                    (string/repeat " " cur-col))
        # different strategy if any dictionaries are elements
        (if has-dict?
          (do
            (each elt items
              (fmt* elt buf)
              #
              (set cur-col (length (array/peek indt-stack)))
              (buffer/push-string buf "\n")
              (buffer/push-string buf (array/peek indt-stack)))
            (when (string/has-suffix? (string "\n" (array/peek indt-stack))
                                      buf)
              (buffer/popn buf (+ 1 (length (array/peek indt-stack))))))
          (do
            (each elt items
              (fmt* elt buf)
              #
              (set cur-col (length (array/peek indt-stack)))
              (buffer/push-string buf " "))
            (when (string/has-suffix? " " buf)
              (buffer/popn buf 1))))
        # XXX: is this correct?
        (set cur-col (length (array/peek indt-stack)))
        (array/pop indt-stack)
        (buffer/push-string buf close-delim))
      #
      (or (= :struct the-type)
          (= :table the-type))
      (let [[open-delim close-delim]
            (cond
              (= :struct the-type) ["{" "}"]
              (= :table the-type) ["@{" "}"])
            items (filter |(and (not= :whitespace (first $))
                                (not= :comment (first $)))
                          (drop 2 an-ast))]
        (+= cur-col (length open-delim))
        (buffer/push-string buf open-delim)
        (array/push indt-stack
                    (string/repeat " " cur-col))
        # format elements
        (for i 0 (/ (length items) 2)
          (def idx (* i 2))
          (fmt* (get items idx) buf)
          #
          (+= cur-col 1)
          (buffer/push-string buf " ")
          #
          (fmt* (get items (inc idx)) buf)
          #
          (set cur-col (length (array/peek indt-stack)))
          (buffer/push-string buf "\n")
          (buffer/push-string buf (array/peek indt-stack)))
        # XXX: is 0 correct, here?
        (set cur-col 0)
        (when (string/has-suffix? (string "\n" (array/peek indt-stack))
                                  buf)
          (buffer/popn buf (+ 1 (length (array/peek indt-stack)))))
        (array/pop indt-stack)
        (buffer/push-string buf close-delim))
      # :fn
      # (do
      #   (buffer/push-string buf "|")
      #   (each elt (drop 2 an-ast)
      #     (fmt* elt buf)))
      # :quasiquote
      # (do
      #   (buffer/push-string buf "~")
      #   (each elt (drop 2 an-ast)
      #     (fmt* elt buf)))
      # :quote
      # (do
      #   (buffer/push-string buf "'")
      #   (each elt (drop 2 an-ast)
      #     (fmt* elt buf)))
      # :splice
      # (do
      #   (buffer/push-string buf ";")
      #   (each elt (drop 2 an-ast)
      #     (fmt* elt buf)))
      # :unquote
      # (do
      #   (buffer/push-string buf ",")
      #   (each elt (drop 2 an-ast)
      #     (fmt* elt buf)))
      )
    buf)
  #
  (fmt* an-ast buf))

(comment

  (def src-0
    ``
    @{main @{:doc "(main)\n\n" :source-map ("dogs.janet" 11 1) :value <function main>} odin @{:source-map ("dogs.janet" 1 1) :value @{:name "Odin" :type "German Shepherd"}} people @{:source-map ("dogs.janet" 4 1) :value ({:dogs (@{:name "Skadi" :type "German Shepherd"} @{:name "Odin" :type "German Shepherd"}) :name "ian"} {:dogs (@{:name "Skadi" :type "German Shepherd"} @{:name "Odin" :type "German Shepherd"}) :name "kelsey"} {:dogs () :name "jeffrey"})} skadi @{:source-map ("dogs.janet" 2 1) :value @{:name "Skadi" :type "German Shepherd"}} :current-file "dogs.janet" :macro-lints @[] :source "dogs.janet"}
    ``)

  (fmt src-0)
  # =>
  @``
   @{main @{:doc "(main)\n\n"
            :source-map ("dogs.janet" 11 1)
            :value <function main>}
     odin @{:source-map ("dogs.janet" 1 1)
            :value @{:name "Odin"
                     :type "German Shepherd"}}
     people @{:source-map ("dogs.janet" 4 1)
              :value ({:dogs (@{:name "Skadi"
                                :type "German Shepherd"}
                              @{:name "Odin"
                                :type "German Shepherd"})
                       :name "ian"}
                      {:dogs (@{:name "Skadi"
                                :type "German Shepherd"}
                              @{:name "Odin"
                                :type "German Shepherd"})
                       :name "kelsey"}
                      {:dogs ()
                       :name "jeffrey"})}
     skadi @{:source-map ("dogs.janet" 2 1)
             :value @{:name "Skadi"
                      :type "German Shepherd"}}
     :current-file "dogs.janet"
     :macro-lints @[]
     :source "dogs.janet"}
   ``

  (def src-1
    ``
    @{main @{:doc "(main)\n\n" :val "hello"} odin @{:value @{:name "Odin" :type "German Shepherd" :smell "good"}} skadi @{:value @{:name "Skadi" :type "German Shepherd"}} :current-file "dogs.janet" :source "dogs.janet"}
    ``)

  (fmt src-1)
  # =>
  @``
   @{main @{:doc "(main)\n\n"
            :val "hello"}
     odin @{:value @{:name "Odin"
                     :type "German Shepherd"
                     :smell "good"}}
     skadi @{:value @{:name "Skadi"
                      :type "German Shepherd"}}
     :current-file "dogs.janet"
     :source "dogs.janet"}
   ``

  (def src-2
    "{:a 1 :b 2 :c 3}")

  (fmt src-2)
  # =>
  @``
   {:a 1
    :b 2
    :c 3}
   ``

  (def src-3
    "{:a {:x 8 :y 9} :b 2 :c 3}")

  (fmt src-3)
  # =>
  @``
   {:a {:x 8
        :y 9}
    :b 2
    :c 3}
   ``

  (def src-4
    "@{:a 1 :b 2 :c 3}")

  (fmt src-4)
  # =>
  @``
   @{:a 1
     :b 2
     :c 3}
   ``

  (def src-5
    "@{:a @{:x 8 :y 9} :b 2 :c 3}")

  (fmt src-5)
  # =>
  @``
   @{:a @{:x 8
          :y 9}
     :b 2
     :c 3}
   ``

  (def src-6
    "{:a {:x 8 :y {:ant 1 :bee 2}} :b 2 :c 3}")

  (fmt src-6)
  # =>
  @``
   {:a {:x 8
        :y {:ant 1
            :bee 2}}
    :b 2
    :c 3}
   ``

  )
