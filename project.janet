(declare-project
  :name "janet-ref"
  :url "https://github.com/sogaiu/janet-ref"
  :repo "git+https://github.com/sogaiu/janet-ref.git")

(declare-source
  :source @["janet-ref"])

(declare-binscript
  :main "jref"
  :is-janet true)

(task "ensure-janet-src" []
  :tags [:dep]
  (unless (os/stat "janet")
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
  (unless (os/stat "janet/TAGS")
    (def dir (os/cwd))
    (os/cd "janet")
    (os/setenv "IJS_OUTPUT_FORMAT" "etags")
    (os/execute ["janet"
                 "../index-janet-source/index-janet-source/idk-janet"]
                :p)
    (os/cd dir))
  (def janet-src-path
    (string (os/cwd) "/janet"))
  (printf "Set `JREF_JANET_SRC_PATH` env var to %s." janet-src-path)
  (print)
  (print "For example:")
  (print)
  (printf "  export JREF_JANET_SRC_PATH=%s" janet-src-path))

