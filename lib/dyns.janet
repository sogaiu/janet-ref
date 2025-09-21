(defn init-dyns
  []
  (def home-dir
    (os/getenv "HOME" (os/getenv "USERPOFILE")))

  (def conf-file-path
    (string home-dir "/.jref.janet"))

  (def conf
    (when (= :file (os/stat conf-file-path :mode))
      (let [conf (try
                   (eval-string (slurp conf-file-path))
                   ([e]
                     (errorf e)))]
        (assert (struct? conf)
                (string/format "expected a struct, found: %n" conf))
        conf)))

  (setdyn :jref-width 68)

  (setdyn :jref-rng
          (math/rng (os/cryptorand 8)))

  (setdyn :jref-src-path
          (os/getenv "JREF_SRC_PATH"
                     (get conf :src-path)))

  (setdyn :jref-janet-src-path
          (os/getenv "JREF_JANET_SRC_PATH"
                     (get conf :janet-src-path)))

  (setdyn :jref-repos-root
          (os/getenv "JREF_REPOS_PATH"
                     (get conf :janet-repos-path)))

  # on windows, https://github.com/adoxa/ansicon may help for
  # pygmentize and rougify
  (setdyn :jref-colorizer (os/getenv "JREF_COLORIZER"))

  # bat -- `bat --list-themes`
  # pygmentize -- `pygmentize -L styles`
  # rougify -- `ls ~/src/rouge/lib/rouge/themes`
  (setdyn :jref-colorizer-style
          (if-let [colorizer-style (os/getenv "JREF_COLORIZER_STYLE")]
            colorizer-style
            (cond
              (= "bat" (dyn :jref-colorizer))
              "gruvbox-dark" # dracula, monokai-extended-origin, OneHalfDark
              #
              (= "pygmentize" (dyn :jref-colorizer))
              "rrt" # dracula, one-dark, monokai, gruvbox-dark
              #
              (= "rougify" (dyn :jref-colorizer))
              "gruvbox" # monokai, thankful_eyes
              "oops")))

  (setdyn :jref-colorizer-filename
          (os/getenv "JREF_COLORIZER_FILENAME"))

  (setdyn :jref-editor
          (os/getenv "JREF_EDITOR"
                     (get conf :editor "nvim")))

  (setdyn :jref-editor-open-at-format
          (if-let [format (os/getenv "JREF_EDITOR_OPEN_AT_FORMAT")]
            (tuple ;(string/split " " format))
            (case (dyn :jref-editor)
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

  (setdyn :jref-editor-filename
          (os/getenv "JREF_EDITOR_FILENAME"
                     (get conf :editor-filename))))

