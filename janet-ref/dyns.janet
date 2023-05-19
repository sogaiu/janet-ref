(defn init-dyns
  []
  (setdyn :jref-width 68)

  (setdyn :jref-rng
          (math/rng (os/cryptorand 8)))

  # XXX
  (def src-root
    (string (os/getenv "HOME") "/src"))

  (setdyn :jref-janet-src-path
          (if-let [j-src-path (os/getenv "JREF_JANET_SRC_PATH")]
            j-src-path
            (string src-root "/janet")))

  (setdyn :jref-repos-root
          (if-let [repos-path (os/getenv "JREF_REPOS_PATH")]
            repos-path
            (string src-root "/janet-repos")))

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
          (if-let [editor (os/getenv "JREF_EDITOR")]
            editor
            "nvim"))

  (setdyn :jref-editor-open-at-format
          (if-let [format (os/getenv "JREF_EDITOR_OPEN_AT_FORMAT")]
            (tuple ;(string/split " " format))
            (case (dyn :jref-editor)
              "emacs"
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
          (os/getenv "JREF_EDITOR_FILENAME")))

