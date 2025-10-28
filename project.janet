(def {:name name
      :url url
      :repo repo}
  (parse (slurp "bundle/info.jdn")))

(declare-project
  :name name
  :url url
  :repo repo)

(declare-source
  :source ["deps" "lib" "init.janet"]
  :prefix "janet-ref")

(declare-binscript
  :main "bin/jref"
  :is-janet true)

(task "cmd-line-tests" []
  :tags [:test]
  (os/execute ["janet"
               "script/run-cmd-line-tests.janet"
               "data/input"
               "data/expected"]
              :p))

