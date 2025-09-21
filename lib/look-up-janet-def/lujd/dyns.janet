(defn init-dyns
  []
  (def home-dir
    (os/getenv "HOME" (os/getenv "USERPOFILE")))

  (def conf-file-path
    (string home-dir "/.lujd.janet"))

  (def conf
    (when (= :file (os/stat conf-file-path :mode))
      (let [conf (try
                   (eval-string (slurp conf-file-path))
                   ([e]
                     (errorf e)))]
        (assert (struct? conf)
                (string/format "expected a struct, found: %n" conf))
        conf)))

  (setdyn :lujd-src-path
          (os/getenv "LUJD_SRC_PATH"
                     (get conf :src-path)))

  (setdyn :lujd-janet-src-path
          (os/getenv "LUJD_JANET_SRC_PATH"
                     (get conf :janet-src-path)))

  (setdyn :lujd-editor
          (os/getenv "LUJD_EDITOR"
                     (get conf :editor "nvim")))

  (setdyn :lujd-editor-open-at-format
          (if-let [format (os/getenv "LUJD_EDITOR_OPEN_AT_FORMAT"
                                     (get conf :editor-open-at-format))]
            (tuple ;(string/split " " format))
            (case (dyn :lujd-editor)
              "emacs"
              ["+%d" "%s"]
              #
              "hx"
              ["+%d" "%s"]
              #
              "kak"
              ["+%d" "%s"]
              #
              "nvim"
              ["+%d" "%s"]
              #
              "subl"
              ["%s:%d"]
              #
              "vim"
              ["+%d" "%s"]
              #
              ["+%d" "%s"])))

  (setdyn :lujd-editor-filename
          (os/getenv "LUJD_EDITOR_FILENAME"
                     (get conf :editor-filename))))

