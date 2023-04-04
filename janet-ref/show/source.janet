(import ../parse/location :as loc)
(import ../parse/etags :as etags)

(defn definition
  [id-name]
  # XXX: dir existence check? better to do before calling?
  (def j-src-path
    (dyn :jref-janet-src-path))

  (when (not (os/stat j-src-path))
    (eprintf "Janet source not available at: %s" j-src-path)
    (eprint "Set JREF_JANET_SRC_PATH to Janet source directory?")
    (break nil))

  (def etags-file-path
    (string j-src-path "/TAGS"))

  (when (not (os/stat etags-file-path))
    (eprintf "Failed to find TAGS file in Janet source directory: %s"
             j-src-path)
    (eprintf "Hint: use index-janet-source's idk-janet to create it")
    (break nil))

  (def etags-content
    (slurp etags-file-path))

  (def etags-table
    (merge ;(peg/match etags/etags-grammar etags-content)))

  (def [line position _ src-path]
    (etags-table id-name))

  (def full-path
    (string j-src-path
            "/"
            src-path))

  (when (not (os/stat full-path))
    (eprintf "Failed to find: %s" full-path)
    (break nil))

  (when (not (string/has-suffix? ".janet" src-path))
    (eprint "Sorry, only works for things defined in .janet files")
    (eprintf "Looks like `%s` is defined at +%d %s" id-name line full-path)
    (break nil))

  # XXX: file existence check?
  (def src (slurp full-path))

  # XXX: atm, only works for janet source (e.g. things in boot.janet)
  (def m
    (peg/match (-> (struct/to-table loc/loc-grammar)
                   # customizing grammar to just get one form
                   (put :main :input))
               src position))

  (if m
    (do
      (print (loc/gen (first m)))
      true)
    (do
      (printf "Sorry, failed to find definition for: %s" id-name)
      false)))

