(import ../parse/location :as l)
(import ../janet-zipper/janet-zipper/zipper :as j)
(import ../janet-location-zipper/loc-jipper :as j)

(defn deprintf
  [fmt & args]
  (when (os/getenv "JREF_VERBOSE")
    (eprintf fmt ;args)))

(def form-table
  {"if-let" true
   "let" true
   "when-let" true})

(comment

  (def src
    ``
    (let [x 1 y 2] (+ x y))
    ``)

  (def zloc
    (-> (l/par src)
        j/zip-down))

  (def let-zloc
    (j/search-from zloc
                   |(match (j/node $)
                      [:symbol _ "let"]
                      true)))

  (def binding-zloc
    (j/right-skip-wsc let-zloc))

  (j/node binding-zloc)
  # =>
  '(:bracket-tuple @{:bc 6 :bl 1 :ec 15 :el 1}
                   (:symbol @{:bc 7 :bl 1 :ec 8 :el 1} "x")
                   (:whitespace @{:bc 8 :bl 1 :ec 9 :el 1} " ")
                   (:number @{:bc 9 :bl 1 :ec 10 :el 1} "1")
                   (:whitespace @{:bc 10 :bl 1 :ec 11 :el 1} " ")
                   (:symbol @{:bc 11 :bl 1 :ec 12 :el 1} "y")
                   (:whitespace @{:bc 12 :bl 1 :ec 13 :el 1} " ")
                   (:number @{:bc 13 :bl 1 :ec 14 :el 1} "2"))

  (-> binding-zloc
      j/down
      j/right
      j/right
      j/right
      # should be whitespace
      (j/edit |(let [original-item (get $ 2)]
                 [:whitespace @{} "\n"]))
      j/root
      l/gen)
  # =>
  ``
  (let [x 1
  y 2] (+ x y))
  ``

  (def src-2
    ``
    (let [x 1 y 2 z 3] (+ x y z))
    ``)

  (def zloc-2
    (-> (l/par src-2)
        j/zip-down))

  (def let-zloc-2
    (j/search-from zloc-2
                   |(match (j/node $)
                      [:symbol _ "let"]
                      true)))

  (def binding-zloc-2
    (j/right-skip-wsc let-zloc-2))

  (j/node binding-zloc-2)
  # =>
  '(:bracket-tuple @{:bc 6 :bl 1 :ec 19 :el 1}
                   (:symbol @{:bc 7 :bl 1 :ec 8 :el 1} "x")
                   (:whitespace @{:bc 8 :bl 1 :ec 9 :el 1} " ")
                   (:number @{:bc 9 :bl 1 :ec 10 :el 1} "1")
                   (:whitespace @{:bc 10 :bl 1 :ec 11 :el 1} " ")
                   (:symbol @{:bc 11 :bl 1 :ec 12 :el 1} "y")
                   (:whitespace @{:bc 12 :bl 1 :ec 13 :el 1} " ")
                   (:number @{:bc 13 :bl 1 :ec 14 :el 1} "2")
                   (:whitespace @{:bc 14 :bl 1 :ec 15 :el 1} " ")
                   (:symbol @{:bc 15 :bl 1 :ec 16 :el 1} "z")
                   (:whitespace @{:bc 16 :bl 1 :ec 17 :el 1} " ")
                   (:number @{:bc 17 :bl 1 :ec 18 :el 1} "3"))

  (-> binding-zloc-2
      j/down
      j/right
      j/right
      j/right
      # should be one target whitespace
      (j/replace [:whitespace @{:message "hello"} "\n"])
      j/right
      j/right
      j/right
      j/right
      # should be another target whitespace
      (j/replace [:whitespace @{:message "smile!"} "\n"])
      j/up
      j/node)
  # =>
  '(:bracket-tuple @{:bc 6 :bl 1 :ec 19 :el 1}
                   (:symbol @{:bc 7 :bl 1 :ec 8 :el 1} "x")
                   (:whitespace @{:bc 8 :bl 1 :ec 9 :el 1} " ")
                   (:number @{:bc 9 :bl 1 :ec 10 :el 1} "1")
                   (:whitespace @{:message "hello"} "\n")
                   (:symbol @{:bc 11 :bl 1 :ec 12 :el 1} "y")
                   (:whitespace @{:bc 12 :bl 1 :ec 13 :el 1} " ")
                   (:number @{:bc 13 :bl 1 :ec 14 :el 1} "2")
                   (:whitespace @{:message "smile!"} "\n")
                   (:symbol @{:bc 15 :bl 1 :ec 16 :el 1} "z")
                   (:whitespace @{:bc 16 :bl 1 :ec 17 :el 1} " ")
                   (:number @{:bc 17 :bl 1 :ec 18 :el 1} "3"))

  (-> binding-zloc-2
      j/down
      j/right
      j/right
      j/right
      # should be one target whitespace
      (j/edit |(let [[_ tbl _] $]
                 [:whitespace (put tbl :message "hello") "\n"]))
      j/right
      j/right
      j/right
      j/right
      # should be another target whitespace
      (j/edit |(let [[_ tbl _] $]
                 [:whitespace (put tbl :message "smile!") "\n"]))
      j/up
      j/node)
  # =>
  '(:bracket-tuple @{:bc 6 :bl 1 :ec 19 :el 1}
                   (:symbol @{:bc 7 :bl 1 :ec 8 :el 1} "x")
                   (:whitespace @{:bc 8 :bl 1 :ec 9 :el 1} " ")
                   (:number @{:bc 9 :bl 1 :ec 10 :el 1} "1")
                   (:whitespace
                     @{:bc 10 :bl 1 :ec 11 :el 1 :message "hello"} "\n")
                   (:symbol @{:bc 11 :bl 1 :ec 12 :el 1} "y")
                   (:whitespace @{:bc 12 :bl 1 :ec 13 :el 1} " ")
                   (:number @{:bc 13 :bl 1 :ec 14 :el 1} "2")
                   (:whitespace
                     @{:bc 14 :bl 1 :ec 15 :el 1 :message "smile!"} "\n")
                   (:symbol @{:bc 15 :bl 1 :ec 16 :el 1} "z")
                   (:whitespace @{:bc 16 :bl 1 :ec 17 :el 1} " ")
                   (:number @{:bc 17 :bl 1 :ec 18 :el 1} "3"))

  )

# XXX: assuming code is not unusual
(defn handle-binding-form
  [binding-zloc]
  (assert (match (j/node binding-zloc)
            [the-type]
            (get {:array true
                  :bracket-array true
                  :bracket-tuple true
                  :tuple true}
                 the-type))
          (string/format "Unexpected node: %p"
                         (j/node binding-zloc)))
  # count how many nodes
  (def n-nodes
    (length (drop 2 (j/node binding-zloc))))
  # move down into the collection
  (var curr-zloc
    (->> binding-zloc
         j/down))
  (assert curr-zloc
          (string/format "Unexpected empty binding collection: %p"
                         (j/node binding-zloc)))
  # every 4th node is target whitespace.  the last 3 nodes should be
  # ignored as they are right before the closing delim and thus should
  # not have a newline placed after them
  (for i 0 (/ (- n-nodes 3) 4)
    (set curr-zloc
         (-> curr-zloc
             j/right
             j/right
             j/right
             (j/edit |(let [[_ tbl _] $]
                        [:whitespace tbl "\n"]))
             j/right)))
  # return the rightmost node
  (j/rightmost curr-zloc))

(comment

  (def src-2
    ``
    (let [x 1 y 2 z 3] (+ x y z))
    ``)

  (def zloc-2
    (-> (l/par src-2)
        j/zip-down))

  (def let-zloc-2
    (j/search-from zloc-2
                   |(match (j/node $)
                      [:symbol _ "let"]
                      true)))

  (def binding-zloc-2
    (j/right-skip-wsc let-zloc-2))

  (def handled-zloc
    (handle-binding-form binding-zloc-2))

  (j/node handled-zloc)
  # =>
  '(:number @{:bc 17 :bl 1 :ec 18 :el 1} "3")

  )

(defn inject-newlines
  [form-zloc]
  (var curr-zloc form-zloc)
  (while (not (j/end? curr-zloc))
    (def result
      (match (j/node curr-zloc)
        [:symbol _ name]
        (when (get form-table name)
          (handle-binding-form (j/right-skip-wsc curr-zloc)))))
    (set curr-zloc
         (if result
           (j/df-next result)
           (j/df-next curr-zloc))))
  #
  curr-zloc)

(comment

  (def src-2
    ``
    (let [x 1 y 2 z 3] (+ x y z))
    ``)

  (def zloc-2
    (-> (l/par src-2)
        j/zip-down))

  (def result-2
    (inject-newlines zloc-2))

  (l/gen (j/root result-2))
  # =>
  ``
  (let [x 1
  y 2
  z 3] (+ x y z))
  ``

  (def src-3
    ``
    (do
      (let [x 1 y 2 z 3] (+ x y z))
      (let [a :x b :y] (string a b)))
    ``)

  (def zloc-3
    (-> (l/par src-3)
        j/zip-down))

  (def result-3
    (inject-newlines zloc-3))

  (->> result-3
       j/root
       l/gen)
  # =>
  ``
  (do
    (let [x 1
  y 2
  z 3] (+ x y z))
    (let [a :x
  b :y] (string a b)))
  ``

  )

(defn process-binding-forms
  [src]
  (def form-zloc
    (-> (l/par src)
        j/zip-down))
  (def result
    (inject-newlines form-zloc))
  #
  (-> result
      j/root
      l/gen))

(comment

  (process-binding-forms
    ``
    (let [_0000c2 (<cfunction fiber/new> (fn []
                                           (do-your-best)) :ie) _0000c3 (<function resume> _0000c2)]
      (if (<function => (<cfunction fiber/status> _0000c2) :error)
        (do
          (def e
            _0000c3)
          (def fib
            _0000c2)
          (debug/stacktrace fib e ""))
        _0000c3))
    ``)
  # =>
  ``
  (let [_0000c2 (<cfunction fiber/new> (fn []
                                         (do-your-best)) :ie)
  _0000c3 (<function resume> _0000c2)]
    (if (<function => (<cfunction fiber/status> _0000c2) :error)
      (do
        (def e
          _0000c3)
        (def fib
          _0000c2)
        (debug/stacktrace fib e ""))
      _0000c3))
  ``

  )
