(import ./index-janet/index-janet/main :as ij)

(defn file-newest?
  [file-path dir-path]
  (def tags-mtime
    (get (os/stat file-path) :modified))
  (var newest-path file-path)
  (with [of (file/temp)]
    (def dir (os/cwd))
    (defer (os/cd dir)
      (os/cd dir-path)
      (def proc (os/execute ["git" "ls-files"] :px
                            {:out of}))
      # XXX: unneeded?
      (file/flush of)
      (file/seek of :set 0)
      (def content (string/trim (file/read of :all)))
      (def lines (string/split "\n" content))
      (each res lines
        (def mtime (get (os/stat res) :modified))
        (when (> mtime tags-mtime)
          (set newest-path res)
          (break)))))
  #
  (= newest-path file-path))

(defn build-index
  [j-src-path file-ext]
  (def dir (os/cwd))
  (defer (os/cd dir)
    (os/cd j-src-path)
    (os/setenv "IJ_OUTPUT_FORMAT" "etags")
    (os/setenv "IJ_FILE_EXTENSION" file-ext)
    (ij/main)))

(defn all-ids-valid?
  [all-ids]
  (and (array? all-ids)
       (all string? all-ids)))

(comment

  (all-ids-valid? @["alice" "bob" "carol"])
  # =>
  true

  (all-ids-valid? [:a :b :c])
  # =>
  false

  (all-ids-valid? @["tom" :wall "jerry"])
  # =>
  false

  )
