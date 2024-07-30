(import ./loc :as l)

(defn init-infra
  [make-grammar]
  (var counter 0)

  (defn issue-id
    []
    (++ counter))

  (def id->node @{})

  (def loc->id @{})

  (defn reset
    []
    (set counter 0)
    (table/clear id->node)
    (table/clear loc->id))

  (defn opaque-node
    [node-type peg-form]
    ~(cmt (capture (sequence (line) (column) (position)
                             ,peg-form
                             (line) (column) (position)))
          ,|(let [id (issue-id)
                  attrs (l/make-attrs ;(tuple/slice $& 0 -2))
                  _ (put loc->id (freeze attrs) id)
                  node [node-type
                        (put attrs :id id)
                        (last $&)]]
              (put id->node id node)
              node)))

  (defn delim-node
    [node-type open-delim close-delim]
    ~(cmt
       (capture
         (sequence
           (line) (column) (position)
           ,open-delim
           (any :input)
           (choice ,close-delim
                   (error
                     (replace (sequence (line) (column) (position))
                              ,|(string/format
                                  (string "line: %p column: %p pos: %p "
                                          "missing %p for %p")
                                  $0 $1 $2 close-delim node-type))))
           (line) (column) (position)))
       ,|(let [id (issue-id)
               attrs (l/make-attrs ;(tuple/slice $& 0 3)
                                   ;(tuple/slice $& (- (- 3) 2) -2))
               _ (put loc->id (freeze attrs) id)
               # add the index position and parent id for each child
               [_ children]
               (reduce (fn add-idx-and-pid
                         [[counter kids] child]
                         # XXX
                         #(d/deprintf "counter: %n" counter)
                         #(d/deprintf "kids: %n" kids)
                         #(d/deprintf "child: %n" child)
                         (def [_ attrs _] child)
                         # XXX
                         #(d/deprintf "type: %n" (type attrs))
                         (unless (= :table (type attrs))
                           (eprintf "child: %n" child)
                           (eprintf "$&: %n" $&))
                         (put attrs :idx counter)
                         (put attrs :pid id)
                         [(inc counter)
                          (array/push kids child)])
                       # index and to-be-filled-with-children
                       [0 @[]]
                       # children before
                       (tuple/slice $& 3 (- (- 3) 2)))
               node [node-type
                     (put attrs :id id)
                     ;children]]
           (put id->node id node)
           node)))

  (def loc-grammar
    (make-grammar {:opaque-node opaque-node
                   :delim-node delim-node}))

  #
  (defn par
    [src &opt start single]
    (default start 0)
    (def top-id 0)
    (def loc-top-level-ast
      (let [ltla (table ;(kvs loc-grammar))]
        (put ltla
             :main ~(sequence (line) (column) (position)
                              :input
                              (line) (column) (position)))
        (table/to-struct ltla)))
    #
    (def top-node
      (if single
        (if-let [[bl bc bp tree el ec ep]
                 (peg/match loc-top-level-ast src start)]
          @[:code
            (put (l/make-attrs bl bc bp el ec ep)
                 :id top-id)
            tree]
          @[:code])
        (if-let [captures (peg/match loc-grammar src start)]
          (let [[bl bc bp] (array/slice captures 0 3)
                [el ec ep] (array/slice captures (dec -3))
                [_ trees] (reduce (fn [[counter kids] child]
                                    (def [_ attrs _] child)
                                    (put attrs :idx counter)
                                    (put attrs :pid top-id)
                                    [(inc counter)
                                     (array/push kids child)])
                                  [0 @[]]
                                  (array/slice captures 3 (dec -3)))]
            (array/insert trees 0
                          :code (put (l/make-attrs bl bc bp el ec ep)
                                     :id top-id)))
          @[:code])))
    #
    (put id->node top-id top-node)
    #
    top-node)
  #
  {:grammar loc-grammar
   :node-table id->node
   :loc-table loc->id
   :issuer issue-id
   :reset reset
   :parse par})

(defn make-cursor
  [node-table &opt node]
  (default node (get node-table 0))
  {:node node
   :table node-table})

(defn right
  [{:node n :table n-tbl}]
  (def [_ attrs _] n)
  (when-let [pid (get attrs :pid)
             idx (get attrs :idx)
             [_ _ & rest] (get n-tbl pid)]
    (when (tuple? rest)
      (when-let [next-sibling (get rest (inc idx))]
        {:node next-sibling
         :table n-tbl}))))

(defn up
  [{:node n :table n-tbl}]
  (def [_ attrs _] n)
  (when-let [pid (get attrs :pid)]
    {:node (get n-tbl pid)
     :table n-tbl}))

(defn down
  [{:node n :table n-tbl}]
  (def [_ _ & rest] n)
  (when (tuple? rest)
    (when-let [first-elt (first rest)]
      (when (tuple? first-elt)
        {:node first-elt
         :table n-tbl}))))

# XXX: using node version of up, down, right might be much better?
# XXX: is this version correct?
(defn df-next-not-quite-correct
  [crs]
  #
  (defn helper
    [a-crs]
    (if-let [down-cand (down a-crs)]
      down-cand
      (if-let [right-cand (right a-crs)]
        right-cand
        # start climbing up if possible
        (do
          (var curr-cand (up a-crs))
          # try to go up until it's possible to go right
          (while curr-cand
            (when (right a-crs)
              (break))
            (set curr-cand (up curr-cand)))
          #
          (if curr-cand
            # start over with right node
            (helper (right curr-cand))
            # reached the top
            nil)))))
  #
  (if-let [result (helper crs)]
    result
    :back-at-top))

(defn df-next
  [crs]
  #
  (defn helper
    [a-crs]
    (if-let [up-cand (up a-crs)]
      (or (right up-cand)
          (helper up-cand))
      :back-at-top))
  # XXX: this part might be off a bit
  (or (down crs)
      (right crs)
      (helper crs)))

(defn rightmost
  [{:node node :table node-table}]
  (def [_ attrs _] node)
  (when-let [pid (get attrs :pid)
             [_ _ & rest] (get node-table pid)]
    (when (tuple? rest) # should not fail
      (when-let [last-sibling (last rest)]
        {:node last-sibling
         :table node-table}))))

(defn left
  [{:node n :table n-tbl}]
  (def [_ attrs _] n)
  (when-let [pid (get attrs :pid)
             idx (get attrs :idx)
             [_ _ & rest] (get n-tbl pid)]
    (when (tuple? rest)
      (when-let [prev-sibling (get rest (dec idx))]
        {:node prev-sibling
         :table n-tbl}))))

(defn df-prev
  [crs]
  #
  (defn helper
    [a-crs]
    (if-let [down-cand (down a-crs)]
      (helper (rightmost down-cand))
      a-crs))
  #
  (if-let [left-cand (left crs)]
    (helper left-cand)
    (up crs)))

