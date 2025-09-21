(import ./index :as idx)
(import ./janet-cursor :as jc)
(import ./janet-query :as jq)

########################################################################

(defn find-janet-tags
  [src]

  '(def src
     (slurp
       (string (os/getenv "HOME") "/src/janet/src/boot/boot.janet")))

  (def query-str
    ``
    (<::type '[capture [choice "defn-" "defn"
                               "defdyn"
                               "defmacro-" "defmacro"
                               "def-" "def"
                               "var-" "var"]]>
     <::name :blob>
     <:...>)
    ``)

  (def [results _ loc->node]
    (jq/query query-str src {:blank-delims [`<` `>`]}))

  (def {:grammar loc-grammar
        :issuer issue-id
        :node-table id->node
        :loc-table loc->id
        :reset reset}
    (jc/make-infra))

  (def m-raw
    (peg/match loc-grammar src))

  # bounds info at indeces 0, 1, 2, and last 3 elements, so slice
  (def m
    (array/slice m-raw 3 (dec (- 3))))

  (def filtered
    (filter (fn [res]
              (def [_ attrs _] (get res ::name))
              (def loc (freeze attrs))
              (def id (loc->id loc))
              (unless id
                (eprintf "no id for loc: %p" loc)
                (break))
              (def parent-tuple
                (jc/up (jc/make-cursor id->node
                                       (get id->node id))))
              (unless parent-tuple (break))
              (def grent-tuple
                (jc/up parent-tuple))
              (unless grent-tuple
                # top-level
                (break true))
              # should succeed given how we got here from below
              (def head-node
                ((jc/down grent-tuple) :node))
              (def [_ _ head-name] head-node)
              # XXX: any other things (e.g. compif)?
              (= "compwhen" head-name))
            results))

  (idx/get-first-lines-and-offsets! src filtered ::name)

  # input:
  #
  # (@{"name" (:symbol @{:bc 6 :bl 10 :ec 10 :el 10} "defn")
  #    :first-line ..
  #    :offset ..
  #    "type" "def"} ...
  #
  # output:
  #
  #  @[["(def defn :macro"
  #    "defn"
  #    (string 10)
  #    (string 106)]
  #    ...]
  #
  (def results
    (seq [tbl :in filtered
          :let [first-line (get tbl :first-line)
                [_ attrs id] (get tbl ::name)
                line-no (get attrs :bl)
                offset (get tbl :offset)]]
      # XXX: hack to capture all ids in an array
      (array/push (dyn :all-ids) id)
      [first-line
       id
       (string line-no)
       (string offset)]))

  results)

########################################################################

(defn index-janet-boot!
  [out-buf]
  (def boot-janet-path "src/boot/boot.janet")
  (def src
    (slurp boot-janet-path))
  #
  (idx/index-file! src boot-janet-path find-janet-tags out-buf))
