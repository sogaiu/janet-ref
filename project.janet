(def {:name name
      :url url
      :repo repo}
  (parse (slurp "info.jdn")))

(declare-project
  :name name
  :url url
  :repo repo)

(task "install" []
  (if (bundle/installed? name)
    (bundle/replace name ".")
    (bundle/install ".")))

(task "cmd-line-tests" []
  :tags [:test]
  (os/execute ["janet"
               "script/run-cmd-line-tests.janet"
               "data/input"
               "data/expected"]
              :p))

