(import ../parse/location-with-unreadable :as loc)

(defn fmt
  [src]
  (def buf @"")
  (def an-ast (loc/par src))
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
      (get {:struct true
            :table true}
           the-type)
      (let [[open-delim close-delim]
            (case the-type
              :struct ["{" "}"]
              :table ["@{" "}"])
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
      # XXX: janet itself won't print things with any of the following?
      (get {:fn true
            :quasiquote true
            :quote true
            :splice true
            :unquote true}
           the-type)
      (let [sigil
            (case the-type
              :fn "|"
              :quasiquote "~"
              :quote "'"
              :splice ";"
              :unquote ",")
            # XXX: should only be one thing left?
            items (filter |(and (not= :whitespace (first $))
                                (not= :comment (first $)))
                          (drop 2 an-ast))]
        (+= cur-col (length sigil))
        (buffer/push-string buf sigil)
        (each elt items
          (fmt* elt buf)))
      #
      (errorf "Unexpected type: %s" the-type)
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
