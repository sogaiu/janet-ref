(declare-project
  :name "look-up-janet-def"
  :url "https://github.com/sogaiu/look-up-janet-def"
  :repo "git+https://github.com/sogaiu/look-up-janet-def.git")

(declare-source
  :source @["lujd"])

(declare-binscript
  :main "bin/lujd"
  :is-janet true)

(task "ensure-tags" []
  (def janet-src-path
    (if-let [jsp (os/getenv "LUJD_JANET_SRC_PATH")]
      jsp
      (do
        (eprintf "Warning: LUJD_JANET_SRC_PATH env var not set")
        # XXX: not quite consistent with lujd's idea of this...
        (string (os/getenv "HOME") "/src/janet"))))
  (def tags-path (string janet-src-path "/TAGS"))
  (def dir (os/cwd))
  (assert (= :directory (os/stat janet-src-path :mode))
          (string "Failed to find janet source directory.\n"
                  "Please specify a full path in LUJD_JANET_SRC_PATH."))

  (def response
    (getline (string/format "Create TAGS under %s? [y/N] " janet-src-path)))

  (when (not (string/has-prefix? "y" (string/ascii-lower response)))
    (eprint "Ok, bye.")
    (os/exit 1))

  (defer (os/cd dir)
    (os/cd janet-src-path)
    (os/setenv "IJ_OUTPUT_FORMAT" "etags")
    (os/execute ["janet"
                 (string dir "/lujd/index-janet/index-janet/main.janet")]
                :px)
    (unless (os/stat tags-path)
      (eprint "Something went wrong, `TAGS` file may not have been created.")
      (os/exit 1)))

  (print "`TAGS` file created.")
  (print)
  (printf "Ensure `LUJD_JANET_SRC_PATH` env var is set to `%s`." janet-src-path)
  (print)
  (print "For example:")
  (print)
  (printf "  export LUJD_JANET_SRC_PATH=%s" janet-src-path))

