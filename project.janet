(declare-project
  :name "janet-ref"
  :url "https://github.com/sogaiu/janet-ref"
  :repo "git+https://github.com/sogaiu/janet-ref.git")

(declare-source
  :source @["janet-ref"])

(declare-binscript
  :main "jref"
  :is-janet true)

(task "cmd-line-tests" []
  :tags [:test]
  (os/execute ["janet"
               "script/run-cmd-line-tests.janet"
               "data/input"
               "data/expected"]
              :p))

