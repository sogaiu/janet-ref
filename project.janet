(declare-project
  :name "janet-ref"
  :url "https://github.com/sogaiu/janet-ref"
  :repo "git+https://github.com/sogaiu/janet-ref.git")

(declare-source
  :source @["janet-ref"])

(declare-binscript
  :main "jref"
  :is-janet true)

(def janet-src-path
  (if-let [jsp (os/getenv "JREF_JANET_SRC_PATH")]
    jsp
    (string (os/cwd) "/janet")))

(task "ensure-janet-src" []
  :tags [:dep]
  (unless (os/stat janet-src-path)
    (def dir (os/cwd))
    (os/execute ["git"
                 "clone"
                 "https://github.com/janet-lang/janet"]
                :p)
    (os/cd dir)))

(task "ensure-index-janet-source" ["ensure-janet-src"]
  :tags [:dep]
  (unless (os/stat "index-janet-source")
    (def dir (os/cwd))
    (os/execute ["git"
                 "clone"
                 "https://github.com/sogaiu/index-janet-source"]
                :p)
    (os/cd dir)))

(task "ensure-tags" ["ensure-index-janet-source"]
  :tags [:dep]
  (def tags-path
    (string janet-src-path "/TAGS"))
  (def dir (os/cwd))
  (os/cd janet-src-path)
  (os/setenv "IJS_OUTPUT_FORMAT" "etags")
  (os/execute ["janet"
               "../index-janet-source/index-janet-source/idk-janet"]
              :px)
  (unless (os/stat tags-path)
    (eprint "Something went wrong, `TAGS` file may not have been created.")
    (os/exit 1))
  #
  (os/cd dir)
  (print "`TAGS` file created.")
  (print)
  (printf "Ensure `JREF_JANET_SRC_PATH` env var is set to `%s`." janet-src-path)
  (print)
  (print "For example:")
  (print)
  (printf "  export JREF_JANET_SRC_PATH=%s" janet-src-path))

