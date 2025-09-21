(declare-project
  :name "index-janet"
  :url "https://github.com/sogaiu/index-janet"
  :repo "git+https://github.com/sogaiu/index-janet.git")

(declare-source
  :source @["index-janet"])

(declare-binscript
  :main "idx-janet"
  :is-janet true)

(def proj-dir
  (os/cwd))

(def janet-src-path
  (if-let [jsp (os/getenv "IJ_JANET_SRC_PATH")]
    jsp
    (string proj-dir "/janet")))

# XXX: could depend on ensure-janet-src, but script fetches if needed
# git and a net connection are required for this part
(task "test-indexing" []
  :tags [:test]
  (os/cd proj-dir)
  (os/execute ["janet"
               "support/test-indexing.janet"]
              :px))

(task "ensure-u-ctags" []
  :tags [:dep]
  (unless (os/execute ["ctags-universal" "--version"] :px)
    (eprint "Failed to find universal ctags, is it available on PATH?")
    (os/exit 1)))

(task "ensure-janet-src" []
  :tags [:dep]
  (os/cd proj-dir)
  (unless (os/stat janet-src-path)
    (def dir (os/cwd))
    (os/execute ["git"
                 "clone"
                 "https://github.com/janet-lang/janet"]
                :p)
    (os/cd dir)))

(task "ensure-tags" ["ensure-janet-src"]
  :tags [:dep]
  (os/cd proj-dir)
  (def tags-path
    (string janet-src-path "/TAGS"))
  (def dir (os/cwd))
  (os/cd janet-src-path)
  (os/setenv "IJ_OUTPUT_FORMAT" "etags")
  (os/execute ["janet"
               (string dir "/idx-janet")]
              :px)
  (unless (os/stat tags-path)
    (eprint "Something went wrong, `TAGS` file may not have been created.")
    (os/exit 1))
  #
  (os/cd dir)
  (print "`TAGS` file created."))

(task "ensure-u-ctags-tags" ["ensure-janet-src" "ensure-u-ctags"]
  :tags [:dep]
  (os/cd proj-dir)
  (def file-ext ".u-ctags")
  (def tags-file-name (string "TAGS" file-ext))
  (def tags-path
    (string janet-src-path "/" tags-file-name))
  (def dir (os/cwd))
  (os/cd janet-src-path)
  (os/setenv "IJS_OUTPUT_FORMAT" "etags")
  (os/setenv "IJS_FILE_EXTENSION" file-ext)
  (os/execute ["janet"
               (string dir "/support/idk-janet.janet")]
              :px)
  (unless (os/stat tags-path)
    (eprintf "Something went wrong, `%s` file may not have been created."
             tags-file-name)
    (os/exit 1))
  #
  (os/cd dir)
  (printf "`%s` file created." tags-file-name))

(task "test-against-u-ctags" ["ensure-tags" "ensure-u-ctags-tags"]
  :tags [:test]
  (os/cd proj-dir)
  # XXX: needs to match what's used in ensure-u-ctags-tags
  (def file-ext ".u-ctags")
  (def tags-path
    (string janet-src-path "/TAGS"))
  (def u-ctags-tags-path
    (string janet-src-path "/TAGS" file-ext))
  (unless (and (os/stat tags-path)
               (os/stat u-ctags-tags-path))
    (eprintf ``
             Both TAGS files must exist:

             * %s
             * %s
             ``
             tags-path u-ctags-tags-path)
    (os/exit 1))
  (def dir (os/cwd))
  (os/cd "support")
  (os/execute ["janet"
               "test-against-u-ctags.janet" tags-path u-ctags-tags-path]
              :px)
  (os/cd dir))

