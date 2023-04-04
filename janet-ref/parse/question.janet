(import ./location :as l)
(import ./zipper :as j)
(import ./loc-jipper :as j)
(import ../random :as rnd)

(defn deprintf
  [fmt & args]
  (when (os/getenv "VERBOSE")
    (eprintf fmt ;args)))

# outline
#
# * (rewrite-test test-zloc)
#   * (find-things test-zloc)
#     * (rnd/choose things)
#       * (blank-thing thing-zloc)

# XXX: make what types of things to find configurable?
(defn find-things
  [test-zloc]
  (def results @[])
  # compare against this to determine whether still a descendant
  (def test-path-len
    (length (j/path test-zloc)))
  (var curr-zloc test-zloc)
  (while (not (j/end? curr-zloc))
    (match (j/node curr-zloc)
      [:symbol]
      (array/push results curr-zloc)
      [:number]
      (array/push results curr-zloc)
      [:keyword]
      (array/push results curr-zloc)
      [:constant]
      (array/push results curr-zloc)
      [:string]
      (array/push results curr-zloc)
      [:long-string]
      (array/push results curr-zloc))
    (set curr-zloc
         (j/df-next curr-zloc))
    # XXX: not 100% sure whether this is something that can be relied on
    (when (or (j/end? curr-zloc)
              # no longer a descendant of test-zloc
              # XXX: verify relying on this is solid
              (<= (length (j/path curr-zloc))
                  test-path-len))
      (break)))
  #
  results)

(comment

  (def src
    ``
    ~(sequence "#"
               (capture (to "=>"))
               "=>"
               (capture (thru -1)))
    ``)

  (map |(j/node $)
       (find-things (-> (l/par src)
                        j/zip-down)))
  # =>
  '@[(:symbol @{:bc 3 :bl 1 :ec 11 :el 1} "sequence")
     (:string @{:bc 12 :bl 1 :ec 15 :el 1} "\"#\"")
     (:symbol @{:bc 13 :bl 2 :ec 20 :el 2} "capture")
     (:symbol @{:bc 22 :bl 2 :ec 24 :el 2} "to")
     (:string @{:bc 25 :bl 2 :ec 29 :el 2} "\"=>\"")
     (:string @{:bc 12 :bl 3 :ec 16 :el 3} "\"=>\"")
     (:symbol @{:bc 13 :bl 4 :ec 20 :el 4} "capture")
     (:symbol @{:bc 22 :bl 4 :ec 26 :el 4} "thru")
     (:number @{:bc 27 :bl 4 :ec 29 :el 4} "-1")]

  )

(defn blank-thing
  [thing-zloc]
  (def node-type
    (get (j/node thing-zloc) 0))
  (var blanked-item nil)
  (var new-thing-zloc nil)
  (cond
    (or (= :symbol node-type)
        (= :constant node-type)
        (= :number node-type)
        (= :string node-type)
        (= :long-string node-type)
        (= :keyword node-type))
    (set new-thing-zloc
         (j/edit thing-zloc
                 |(let [original-item (get $ 2)]
                    (set blanked-item original-item)
                    [node-type
                     (get $ 1)
                     (string/repeat "_" (length original-item))])))
    #
    (do
      (eprintf "Unexpected node-type: %s" node-type)
      (set new-thing-zloc thing-zloc)))
  [new-thing-zloc blanked-item])

(comment

  (def src
    ``
    ~(sequence "#"
               (capture (to "=>"))
               "=>"
               (capture (thru -1)))
    ``)

  (def thing-zloc
    (first (find-things (-> (l/par src)
                            j/zip-down))))

  (def [new-thing blanked-item]
    (blank-thing thing-zloc))

  (j/node new-thing)
  # =>
  [:symbol @{:bc 3 :bl 1 :ec 11 :el 1} "________"]

  blanked-item
  # =>
  "sequence"

  (->> (blank-thing thing-zloc)
       first
       j/root
       l/gen)
  # =>
  ``
  ~(________ "#"
             (capture (to "=>"))
             "=>"
             (capture (thru -1)))
  ``

  )

(defn rewrite-test-zloc
  [test-zloc]
  (deprintf "test:")
  (deprintf (l/gen (j/node test-zloc)))
  # find how many "steps" back are needed to "get back" to original spot
  (var steps 0)
  (var chosen-thing-zloc nil)
  (def test-node-type
    (get (j/node test-zloc) 0))
  (cond
    (or (= :string test-node-type)
        (= :long-string test-node-type)
        (= :keyword test-node-type)
        (= :constant test-node-type)
        (= :number test-node-type))
    (do
      (deprintf "test was a %s" test-node-type)
      (set chosen-thing-zloc test-zloc))
    #
    (get {:tuple true
          :bracket-tuple true
          :quote true
          :quasiquote true
          :splice true
          :struct true
          :table true} test-node-type)
    (let [things (find-things test-zloc)]
      # XXX
      (deprintf "test was a %s" test-node-type)
      # XXX
      (deprintf "Number of things found: %d" (length things))
      (when (empty? things)
        # XXX
        (eprint "Failed to find a thing")
        (break [nil nil]))
      (each thng things
        (deprintf (l/gen (j/node thng))))
      (set chosen-thing-zloc
           (rnd/choose things))
      (deprintf "chosen: %s" (l/gen (j/node chosen-thing-zloc))))
    #
    (do
      (eprint "Unexpected node-type:" test-node-type)
      (break [nil nil])))
  # find how many steps away we are from test-zloc's node
  (var curr-zloc chosen-thing-zloc)
  # XXX: compare (attrs ...) results instead of gen / node
  (def test-str
    (l/gen (j/node test-zloc)))
  (while curr-zloc
    # XXX: expensive?
    # XXX: compare (attrs ...) results instead -- should be faster
    #      attrs should be unique inside the tree(?)
    (when (= (l/gen (j/node curr-zloc))
             test-str)
      (break))
    (set curr-zloc
         (j/df-prev curr-zloc))
    (++ steps))
  # XXX
  (deprintf "steps: %d" steps)
  # XXX: check not nil?
  (var [curr-zloc blanked-item]
    (->> chosen-thing-zloc
         blank-thing))
  # get back to "test-zloc" position
  (for i 0 steps
    (set curr-zloc
         (j/df-prev curr-zloc)))
  # XXX
  #(deprintf "curr-zloc: %M" curr-zloc)
  #
  [curr-zloc blanked-item])

(defn rewrite-test
  [test-zloc]
  (when-let [[rewritten-zloc blanked-item]
             (rewrite-test-zloc test-zloc)]
    [(->> rewritten-zloc
         j/root
         l/gen)
     blanked-item]))

(comment

  (def src
    ``
    (peg/match ~(error "a")
               "a")
    ``)

  (def [result blanked-item]
    (rewrite-test (->> (l/par src)
                       j/zip-down)))

  (or (= "peg/match" blanked-item)
      (= "error" blanked-item)
      (= "\"a\"" blanked-item))
  # =>
  true

  (or (= result
         ``
         (_________ ~(error "a")
                    "a")
         ``)
      (= result
         ``
         (peg/match ~(_____ "a")
                    "a")
         ``)
      (= result
         ``
         (peg/match ~(error ___)
                    "a")
         ``)
      (= result
         ``
         (peg/match ~(error "a")
                    ___)
         ``))
  # =>
  true

  )

