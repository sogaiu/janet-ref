# notes:
#
# * depends on structure of files in margaret's examples directory

(import ./argv :as av)
(import ./colorize :as col)
(import ./completion :as compl)
(import ./doc :as doc)
(import ./dyns :as d)
(import ./env-vars :as evars)
(import ./format/bindings :as bind)
(import ./format/code :as code)
(import ./format/data :as data)
(import ./index-janet/index-janet/main :as ij)
(import ./jandent/jandent/indent :as indent)
(import ./print :as pr)
(import ./quiz :as qu)
(import ./src :as src)
(import ./things :as things)
(import ./usages :as usages)

(def usage
  `````
  usage: jref [THING] [OPTION]..
         jref [OPTION]... [THING]

  View Janet information for things such as functions,
  macros, special forms, etc.

  Parameters:

    thing    name of function, macro, special form, etc.

  Options:

    -h, --help               show this output

    -d, --doc                show doc
    -q, --quiz               show quiz question
    -s, --src                show source [1]
    -u, --usage              show usages

    -p, --pprint             pretty-print data

    -f, --format             format code
    -i, --indent             indent code
    -e, --eval               evaluate code
    -m, --macex1             macroexpand code

    -r, --repl               run a repl

        --env-vars           show tweakable environment vars

        --bash-completion    output bash-completion bits
        --fish-completion    output fish-completion bits
        --zsh-completion     output zsh-completion bits

        --raw-all            show all things to help completion

        --bindings

    -g, --grep
    -t, --todo

  With THING, but no options, show docs and usages.

  With the `-d` or `--doc` option, show docs for THING, or if
  none specified, for a randomly chosen one.

  With the `-q` or `--quiz` option, show quiz question for
  specified THING, or if none specified, for a randonly
  chosen one.

  With the `-s` or `--src` option, show source code for
  specified THING, or if none specified, for a randonly
  chosen one [1] in an editor [2].

  With the `-u` or `--usage` option, show usages for
  specified THING, or if none specified, for a randomly
  chosen one.

  With no arguments, lists all things.

  Be careful to quote shortnames (e.g. *, ->, >, <-, etc.)
  appropriately so the shell doesn't process them in an
  undesired fashion.

  ---

  [1] Lookups are performed via an index of the Janet source
  code. The index (a file named `TAGS.jref`) is built from a
  local copy of the Janet source code and placed in the same
  directory.

  The location of a local copy of the Janet source code can
  be specified via a configuration file or an environment
  variable.

  For the configuration file approach, create a file named
  `.jref.janet` in your `HOME` / `USERPROFILE` directory. The
  content should be something like:

  ```
  {:janet-src-path
   (string (os/getenv "HOME") "/src/janet")}
  ```

  That is, the file should end with a struct that has at
  least the key `:janet-src-path` and its associated value
  should evaluate to a full path to Janet source code.

  For the environment variable approach, set
  `JREF_JANET_SRC_PATH` to a full path of a local copy of the
  Janet source code.

  [2] The default editor is `nvim`. Other supported editors
  include: `emacs`, `hx`, `kak`, `subl`, and `vim`.

  A particular editor other than the default can be
  configured via a file (see info about `.jref.janet` above)
  or via an environment variable.

  For the configuration file approach, in a file named
  `.jref.janet` in your `HOME` / `USERPROFILE` directory, add
  an appropriate key-value pair to a struct which ends up as
  the last value to be evaluated in the file.

  The key should be `:editor` and the value should be one of:
  `emacs`, `hx`, `kak`, `nvim`, `subl`, or `vim`.

  An example `.jref.janet` might look like:

  ```
  {:editor "emacs"
   :janet-src-path
   (string (os/getenv "HOME") "/src/janet")}
  ```

  For the environment variable approach, `JREF_EDITOR` should
  be set to one of: `emacs`, `hx`, `kak`, `nvim`, `subl`, or
  `vim`.
  `````)

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

  (d/init-dyns)

  (def [opts rest errs]
    (av/parse-argv argv))

  (when (not (empty? errs))
    (each err errs
      (eprint "jref: " err))
    (eprint "Try 'jref -h' for usage text.")
    (os/exit 1))

  # the code beyond here is longish, but it's straight-forward, mostly
  # just dispatching based on key-value pair existence in opts

  # usage
  (when (opts :help)
    (print usage)
    (os/exit 0))

  # show tweakable env vars
  (when (opts :env-vars)
    (print evars/docstring)
    (os/exit 0))

  # possibly handle dumping completion bits
  (when (compl/maybe-handle-dump-completion opts)
    (os/exit 0))

  # help completion by showing a raw list of relevant things
  (when (or (opts :raw-all) (opts :todo))
    (def file-names
      (try
        (usages/all-file-names)
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
      (each thing things
        (things/print-escaped-maybe thing))
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
    (->> (or thing (file/read stdin :all))
         data/fmt
         col/colorize
         print)
    (os/exit 0))

  # XXX: organize this later
  (when (opts :macex1)
    (->> (or thing (file/read stdin :all))
         (string/format "(macex1 '%s)")
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
    (->> (or thing (file/read stdin :all))
         eval-string
         (string/format "%n")
         data/fmt
         col/colorize
         print)
    (os/exit 0))

  # XXX: organize this later
  (when (opts :format)
    (->> (or thing (file/read stdin :all))
         code/fmt
         bind/process-binding-forms
         indent/format
         col/colorize
         print)
    (os/exit 0))

  # XXX: organize this later
  (when (opts :indent)
    (->> (or thing (file/read stdin :all))
         indent/format
         col/colorize
         print)
    (os/exit 0))

  (when (opts :bindings)
    (def binding-tbl
      @{:macro @[]})
    (each name (all-bindings root-env true)
      (def info
        (dyn (symbol name)))
      # order is important here
      (if (info :macro)
        (array/push (binding-tbl :macro) name)
        (do
          (def the-type
            (type (info :value)))
          (if (nil? (binding-tbl the-type))
            (put binding-tbl the-type @[name])
            (array/push (binding-tbl the-type) name)))))
    (if thing
      (when-let [vals (get binding-tbl (keyword thing))]
        (each elt (sort vals)
          (print elt)))
      (eachp [k v] binding-tbl
        (unless (= k :nil)
          (print k)
          (each elt (sort v)
            (print "  " elt))
          (print))))
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
        (usages/all-file-names)
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
    (def cmd-line ["rg"
                   thing
                   "--max-columns" "120"
                   "--max-columns-preview"
                   "--glob" "*.janet"
                   "--glob" "*.jdn"
                   "--glob" "*.cgen"
                   repos-path])
    (def code (os/execute cmd-line :p))
    # ripgrep exits with 1 if no match was found and there were no errors
    (if (or (zero? code) (one? code))
      (os/exit 0)
      (os/exit 1)))

  # XXX: organize this later
  (when (opts :src)
    (def j-src-path (dyn :jref-janet-src-path))
    (when (or (nil? j-src-path)
              (not= :directory (os/stat j-src-path :mode)))
      (eprint "Failed to find Janet source directory.")
      (eprint "Please set the env var JREF_JANET_SRC_PATH to a")
      (eprint "full path of Janet source or arrange for an")
      (eprint "appropriate config file.  Please see the program")
      (eprint "usage text for details.")
      (os/exit 1))

    (def file-ext ".jref")
    (def tags-fname (string "TAGS" file-ext))
    (def etags-file-path (string j-src-path "/" tags-fname))

    (when (not (os/stat etags-file-path))
      (eprintf "Failed to find index file %s in Janet directory: %s"
               tags-fname j-src-path)
      (eprintf "Attempting to create index file at: %s" etags-file-path)
      (def dir (os/cwd))
      (defer (os/cd dir)
        (os/cd j-src-path)
        (os/setenv "IJ_OUTPUT_FORMAT" "etags")
        (os/setenv "IJ_FILE_EXTENSION" file-ext)
        (ij/main))
      (when (not (os/stat etags-file-path))
        (eprintf "Failed to create index file at: %s" etags-file-path)
        (os/exit 1))
      (printf "Created index file at: `%s`" etags-file-path))
    #
    (def etags-content
      (try
        (slurp etags-file-path)
        ([e]
          (eprintf "Failed to read TAGS file: %s" etags-file-path)
          (os/exit 1))))
    (src/definition thing etags-content j-src-path)
    (os/exit 0))

  # show docs, usages, or quizzes for a thing
  (let [[file-path _]
        (module/find (string "janet-ref/usages/"
                             (things/escape-sym-name thing)))]

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
        (if (get things/special-forms-table thing)
          (doc/special-form-doc content)
          (doc/thing-doc thing)))
      (each line lines
        (print line)))

    (when (opts :usage)
      (var limit nil)
      # some special behavior
      (when (opts :doc)
        (set limit 3)
        (print)
        (pr/print-separator)
        (print))
      #
      (def [res buf]
        (usages/thing-usages content limit))
      (if res
        (print (col/colorize buf))
        (do
          (eprint buf)
          (os/exit 1))))

    (when (opts :quiz)
      (qu/thing-quiz content))))

