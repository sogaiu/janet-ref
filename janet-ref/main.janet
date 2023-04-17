# notes:
#
# * depends on structure of files in margaret's examples directory

(import ./argv :as av)
(import ./colorize :as col)
(import ./completion :as compl)
(import ./format/bindings :as bind)
(import ./format/code :as code)
(import ./format/data :as data)
(import ./format/jandent/indent :as indent)
(import ./doc :as doc)
(import ./print :as pr)
(import ./quiz :as qu)
(import ./src :as src)
(import ./things :as things)
(import ./usages :as us)

(def usage
  ``
  Usage: jref [option] [thing]

  View Janet information for things such as functions, macros,
  special forms, etc.

    -h, --help                   show this output

    -d, --doc [<thing>]          show doc
    -q, --quiz [<thing>]         show quiz question
    -s, --src [<thing>]          show source [1]
    -u, --usage [<thing>]        show usages

    -p, --pprint [<data>]        pretty-print data

    -f, --format [<code>]        format code
    -i, --indent [<code>]        indent code
    -e, --eval [<code>]          evaluate code
    -m, --macex1 [<code>]        macroexpand code

    -r, --repl                   run a repl

    --bash-completion            output bash-completion bits
    --fish-completion            output fish-completion bits
    --zsh-completion             output zsh-completion bits
    --raw-all                    show all things to help completion

  With a thing, but no options, show docs and usages.

  With the `-d` or `--doc` option, show docs for thing, or if none
  specified, for a randomly chosen one.

  With the `-q` or `--quiz` option, show quiz question for specified
  thing, or if none specified, for a randonly chosen one.

  With the `-s` or `--src` option, show source code for specified
  thing, or if none specified, for a randonly chosen one [1].

  With the `-u` or `--usage` option, show usages for specified thing,
  or if none specified, for a randomly chosen one.

  With no arguments, lists all things.

  Be careful to quote shortnames (e.g. *, ->, >, <-, etc.)
  appropriately so the shell doesn't process them in an undesired
  fashion.

  ---

  [1] For source code lookups to work, the Janet source code needs to
  be available locally and a suitable `TAGS` file needs to exist.

  The `ensure-tags` jpm task can perform most of this setup, but
  universal ctags needs to be installed as well.

  Once universal ctags installation has been verified, invoke:

    `jpm run ensure-tags`

  This should clone the janet source + some extra bits to create the
  `TAGS` file.  Once cloning is complete, the TAGS file should get
  created automatically (this is where universal ctags is used).
  The `TAGS` file should end up in the `janet` subdirectory.
  ``)

(def special-forms-table
  {"def" true
   "var" true
   "fn" true
   "do" true
   "quote" true
   "if" true
   "splice" true
   "while" true
   "break" true
   "set" true
   "quasiquote" true
   "unquote" true
   "upscope" true})

# XXX: need to add a lot here or use some kind of
#      pattern matching?
# XXX: anything platform-specific?
(def escape-table
  {"'"   true "*"  true ";" true
   "->>" true "->" true ">" true
   "<-"  true "<"  true
   "|"   true "~"  true}  )

(defn all-usage-file-names
  []
  (let [[file-path _]
        (module/find "janet-ref/usages/0.all-the-things")]
    (when file-path
      (let [dir-path
            (string/slice file-path 0
                          (last (string/find-all "/" file-path)))]
        (unless (os/stat dir-path)
          (errorf "Unexpected directory non-existence:" dir-path))
        #
        (os/dir dir-path)))))

(defn all-the-sharp-things
  [content]
  (def m-lines @[])
  (def lines
    (string/split "\n" content))
  (when (empty? (array/peek lines))
    (array/pop lines))
  (each line lines
    (array/push m-lines
                (->> line
                     (peg/match ~(sequence "# "
                                           (capture (to -1))))
                     first)))
  #
  m-lines)

(defn main
  [& argv]
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
  #
  (setdyn :jref-colorizer (os/getenv "JREF_COLORIZER"))
  # XXX: only applies to:
  #
  #      bat -- `bat --list-themes`
  #      pygmentize -- `pygmentize -L styles`
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
              "oops")))

  (def [opts rest]
    (av/parse-argv argv))

  # usage
  (when (opts :help)
    (print usage)
    (os/exit 0))

  # possibly handle dumping completion bits
  (when (compl/maybe-handle-dump-completion opts)
    (os/exit 0))

  # help completion by showing a raw list of relevant things
  (when (or (opts :raw-all) (opts :todo))
    (def file-names
      (try
        (all-usage-file-names)
        ([e]
          (eprint "Problem determining all things.")
          (eprint e)
          nil)))
    (unless file-names
      (eprintf "Failed to find all things.")
      (os/exit 1))
    (def things
      (sort (things/all-things file-names)))
    (cond
      (opts :raw-all)
      (do
        # XXX: not sure if this quoting will work on windows...
        (defn print-escaped-maybe
          [a-str]
          (if (get escape-table a-str)
            (print `"` a-str `"`)
            (print a-str)))
        (each thing things
          (print-escaped-maybe thing)))
      #
      (opts :todo)
      (do
        (def tbl
          (table ;(interpose true
                             (map symbol things))
                 true))
        (each item (all-bindings)
          (unless (get tbl item)
            (print item))))
      #
      (do
        (eprintf "Should not have gotten here...opts: %p" opts)
        (os/exit 1)))
    (os/exit 0))

  # check if there was a thing specified
  (var thing
    (let [cand (first rest)]
      (if-let [alias (get things/aliases-table cand)]
        alias
        cand)))

  # XXX: organize this later
  (when (opts :repl)
    (eval-string "(import janet-ref/repl) (repl/cli-main @[])")
    (os/exit 0))

  # XXX: organize this later
  (when (opts :pprint)
    (def to-handle
      (if thing
        thing
        (file/read stdin :all)))
    (->> to-handle
         data/fmt
         col/colorize
         print)
    (os/exit 0))

  # XXX: organize this later
  (when (opts :macex1)
    (def to-handle
      (if thing
        thing
        (file/read stdin :all)))
    (->> (string "(macex1 '" to-handle ")")
         eval-string
         (string/format "%n")
         code/fmt
         bind/process-binding-forms
         indent/format
         col/colorize
         print)
    (os/exit 0))

  # XXX: organize this later
  (when (opts :eval)
    (def to-handle
      (if thing
        thing
        (file/read stdin :all)))
    (->> (eval-string to-handle)
         (string/format "%n")
         data/fmt
         col/colorize
         print)
    (os/exit 0))

  # XXX: organize this later
  (when (opts :format)
    (def to-handle
      (if thing
        thing
        (file/read stdin :all)))
    (->> to-handle
         code/fmt
         bind/process-binding-forms
         indent/format
         col/colorize
         print)
    (os/exit 0))

  # XXX: organize this later
  (when (opts :indent)
    (def to-handle
      (if thing
        thing
        (file/read stdin :all)))
    (->> to-handle
         indent/format
         col/colorize
         print)
    (os/exit 0))

  # if no thing found and no options, show info about all things
  (when (and (nil? thing)
             (empty? opts))
    (if-let [[file-path _]
             (module/find "janet-ref/usages/0.all-the-things")]
      (do
        (unless (os/stat file-path)
          (eprintf "Failed to find file: %s" file-path)
          (os/exit 1))
        (def content
          (try
            (slurp file-path)
            ([e]
              (eprintf "Failed to read file: %s" file-path)
              (os/exit 1))))
        (def lines
          (all-the-sharp-things content))
        (each line lines
          (print line))
        (os/exit 0))
      (do
        (eprint "Hmm, something is wrong, failed to find all the things.")
        (os/exit 1))))

  # ensure a thing beyond this form by choosing one if needed
  (unless thing
    (def file-names
      (try
        (all-usage-file-names)
        ([e]
          (eprint "Problem determining all things.")
          (eprint e)
          nil)))
    (unless file-names
      (eprintf "Failed to find all things.")
      (os/exit 1))
    (set thing
      (things/choose-random-thing file-names)))

  # XXX: organize this later
  (when (opts :grep)
    (def repos-path
      (dyn :jref-repos-root))
    # XXX
    (os/execute ["rg"
                 thing
                 "--max-columns" "120"
                 "--max-columns-preview"
                 "--glob" "*.janet"
                 "--glob" "*.jdn"
                 "--glob" "*.cgen"
                 repos-path]
                :px)
    (os/exit 0))

  # XXX: organize this later
  (when (opts :src)
    (def j-src-path
      (dyn :jref-janet-src-path))
    (when (not (os/stat j-src-path))
      (eprintf "Janet source not available at: %s" j-src-path)
      (eprint "Set JREF_JANET_SRC_PATH to Janet source directory?")
      (os/exit 1))
    (def etags-file-path
      (string j-src-path "/TAGS"))
    (when (not (os/stat etags-file-path))
      (eprintf "Failed to find `TAGS` file in Janet source directory: %s"
               j-src-path)
      (eprint)
      (eprint "To create the `TAGS` file:")
      (eprint)
      (eprint "1. Ensure universal ctags is installed, and")
      (eprint "2. Invoke `jpm run ensure-tags`")
      (os/exit 1))
    #
    (def etags-content
      (try
        (slurp etags-file-path)
        ([e]
          (eprintf "Failed to read TAGS file: %s" etags-file-path)
          (os/exit 1))))
    (def [res lang buf]
      (src/definition thing etags-content j-src-path))
    (if res
      (do
        (print (col/colorize buf lang))
        (os/exit 0))
      (do
        (eprint buf)
        (os/exit 1))))

  # show docs, usages, or quizzes for a thing
  (let [[file-path _]
        (module/find (string "janet-ref/usages/" (escape-sym-name thing)))]

    (unless file-path
      (eprintf "Did not find file for `%s`" thing)
      # XXX: temporary hack until usages are filled in?
      (eprint "Trying to show source instead.")
      (eprint)
      (main "restart" "-s" ;(drop 1 argv))
      # XXX: end of hack
      # XXX: won't get here because of line above
      (os/exit 1))

    (unless (os/stat file-path)
      (eprintf "Hmm, something is wrong, failed to find file: %s"
               file-path)
      (os/exit 1))

    (def content
      (try
        (slurp file-path)
        ([e]
          (eprintf "Failed to read file: %s" file-path)
          (os/exit 1))))

    (when (empty? opts)
      (put opts :doc true)
      (put opts :usage true))

    (when (opts :doc)
      (def lines
        (if (get special-forms-table thing)
          (doc/special-form-doc content)
          (doc/thing-doc thing)))
      (each line lines
        (print line)))

    (when (opts :usage)
      (var limit nil)
      # some special behavior
      (when (opts :doc)
        (set limit 3)
        (unless (get special-forms-table thing)
          (print))
        (pr/print-separator)
        (print))
      #
      (def [res buf]
        (us/thing-usages content limit))
      (if res
        (print (col/colorize buf))
        (do
          (eprint buf)
          (os/exit 1))))

    (when (opts :quiz)
      (qu/thing-quiz content))))

