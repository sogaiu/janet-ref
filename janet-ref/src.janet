(import ./index-janet/index-janet/etags :as etags)

(defn open-editor-at
  [line full-path]
  (unless (dyn :jref-editor)
    (eprintf "Please specify an editor via JREF_EDITOR")
    (break nil))
  #
  (def editor-filename
    (if-let [editor-filename (dyn :jref-editor-filename)]
      editor-filename
      (if (= :windows (os/which))
        (string (dyn :jref-editor) ".exe")
        (dyn :jref-editor))))
  (def open-at-format
    (dyn :jref-editor-open-at-format))
  (def oaf-len
    (length open-at-format))
  (cond
    # sublimetext uses: path:line
    (= 1 oaf-len)
    (do
      (def open-at-arg
        (string/format ;open-at-format full-path line))
      #
      (os/execute [editor-filename open-at-arg]
                  :p))
    # emacs, kak, nvim, neovim use: +line path
    (= 2 oaf-len)
    (do
      (def [line-fmt path-fmt]
        (dyn :jref-editor-open-at-format))
      (def line-arg
        (string/format line-fmt line))
      (def path-arg
        (string/format path-fmt full-path))
      #
      (os/execute [editor-filename
                   line-arg path-arg]
                  :p))
    #
    (eprintf "Don't know how to handle an open at format with %d parts"
             oaf-len)))

(defn definition
  [id-name etags-content j-src-path]
  (def etags-table
    (merge ;(peg/match etags/etags-grammar etags-content)))

  (def result (etags-table id-name))

  (unless result
    (eprintf "Failed to find id: %s" id-name)
    (break nil))

  (def line (first result))

  (def src-path (last result))

  (def full-path
    (string j-src-path "/" src-path))

  (when (not (os/stat full-path))
    (eprintf "Failed to find file: %s" full-path)
    (break nil))

  (open-editor-at line full-path)

  true)

