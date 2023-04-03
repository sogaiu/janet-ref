# notes:
#
# * depends on structure of files in margaret's examples directory

(import ./argv :as av)
(import ./completion :as compl)
(import ./random :as rnd)
(import ./show/doc :as doc)
(import ./show/examples :as ex)
(import ./show/misc :as misc)
(import ./show/questions :as qu)
(import ./view :as view)

(def usage
  ``
  Usage: jref [option] [thing]

  View Janet information for things such as functions, macros,
  special forms, etc.

    -h, --help                  show this output

    -d, --doc [<thing>]         show doc
    -x, --eg [<thing>]          show examples
    -q, --quiz [<thing>]        show quiz question

    --bash-completion           output bash-completion bits
    --fish-completion           output fish-completion bits
    --zsh-completion            output zsh-completion bits
    --raw-all                   show all things to help completion

  With a thing, but no options, show docs and examples.

  With the `-d` or `--doc` option, show docs for thing, or if none
  specified, for a randomly chosen one.

  With the `-x` or `--eg` option, show examples for specified thing,
  or if none specified, for a randomly chosen one.

  With the `-q` or `--quiz` option, show quiz question for specified
  thing, or if none specified, for a randonly chosen one.

  With no arguments, lists all things.

  Be careful to quote shortnames (e.g. *, ->, >, <-, etc.)
  appropriately so the shell doesn't process them in an undesired
  fashion.
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

(def examples-table
  # XXX: what's missing?
  {"|" "fn"
   "~" "quasiquote"
   "'" "quote"
   ";" "splice"
   "," "unquote"})

(defn all-example-file-names
  []
  (let [[file-path _]
        (module/find "janet-ref/examples/0.all-the-things")]
    (when file-path
      (let [dir-path
            (string/slice file-path 0
                          (last (string/find-all "/" file-path)))]
        (unless (os/stat dir-path)
          (errorf "Unexpected directory non-existence:" dir-path))
        #
        (os/dir dir-path)))))

(defn all-things
  [file-names]
  (def things
    (->> file-names
         # drop .janet extension
         (map |(string/slice $ 0
                             (last (string/find-all "." $))))
         # only keep things that have names
         (filter |(not (string/has-prefix? "0." $)))))
  # add aliases
  (each alias (keys examples-table)
    (let [thing (get examples-table alias)]
      (unless (string/has-prefix? "0." thing)
        (when (index-of thing things)
          (array/push things alias)))))
  #
  things)

(defn choose-random-thing
  [file-names]
  (let [all-idx (index-of "0.all-the-things.janet" file-names)]
    (unless all-idx
      (errorf "Unexpected failure to find file with all the things: %M"
              file-names))
    (def file-name
      (rnd/choose (array/remove file-names all-idx)))
    # return name without extension
    (string/slice file-name 0
                  (last (string/find-all "." file-name)))))

(defn main
  [& argv]
  (setdyn :jref-rng
          (math/rng (os/cryptorand 8)))

  (view/configure)

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
  (when (opts :raw-all)
    (def file-names
      (try
        (all-example-file-names)
        ([e]
          (eprint "Problem determining all things.")
          (eprint e)
          nil)))
    (unless file-names
      (eprintf "Failed to find all things.")
      (os/exit 1))
    (doc/all-things (all-things file-names))
    (os/exit 0))

  # check if there was a thing specified
  (var thing
    (let [cand (first rest)]
      (if-let [alias (get examples-table cand)]
        alias
        cand)))

  # XXX: organize this later
  (when (and (one? (length opts))
             (opts :repl))
    (eval-string "(import janet-ref/repl) (repl/cli-main @[])")
    (os/exit 0))

  # if no thing found and no options, show info about all things
  (when (and (nil? thing)
             (nil? (opts :doc))
             (nil? (opts :eg))
             (nil? (opts :quiz)))
    (if-let [[file-path _]
             (module/find "janet-ref/examples/0.all-the-things")]
      (do
        (unless (os/stat file-path)
          (eprintf "Failed to find file: %s" file-path)
          (os/exit 1))
        (doc/doc (slurp file-path))
        (os/exit 0))
      (do
        (eprint "Hmm, something is wrong, failed to find all the things.")
        (os/exit 1))))

  # ensure a thing beyond this form by choosing one if needed
  (unless thing
    (def file-names
      (try
        (all-example-file-names)
        ([e]
          (eprint "Problem determining all things.")
          (eprint e)
          nil)))
    (unless file-names
      (eprintf "Failed to find all things.")
      (os/exit 1))
    (set thing
      (choose-random-thing file-names)))

  # XXX: organize this later
  (when (and (one? (length opts))
             (opts :macex1))
    (printf "%p"
            (eval-string (string "(macex1 '" thing ")")))
    (os/exit 0))

  # XXX: organize this later
  (when (and (one? (length opts))
             (opts :eval))
    (printf "%p"
            (eval-string thing))
    (os/exit 0))

  # show docs, examples, and/or quizzes for a thing
  (let [[file-path _]
        (module/find (string "janet-ref/examples/" thing))]

    # XXX: remove this hack later?
    (when (and (one? (length opts))
               (opts :doc))
      (if (get special-forms-table thing)
        # XXX: should check file existence, but will be removing this
        #      code anyway
        (doc/special-form-doc (slurp file-path))
        (doc/thing-doc thing))
      (os/exit 0))

    (unless file-path
      (eprintf "Did not find file for `%s`" thing)
      (os/exit 1))

    (unless (os/stat file-path)
      (eprintf "Hmm, something is wrong, failed to find file: %s"
               file-path)
      (os/exit 1))

    # XXX: could check for failure here
    (def content
      (slurp file-path))

    (when (or (and (opts :doc) (opts :eg))
              (and (nil? (opts :doc))
                   (nil? (opts :eg))
                   (nil? (opts :quiz))))
      (if (get special-forms-table thing)
        (doc/special-form-doc content)
        (do
          (doc/thing-doc thing)
          (print)))
      (misc/print-separator)
      (print)
      (print)
      (ex/thing-examples content)
      (os/exit 0))

    (when (opts :doc)
      (if (get special-forms-table thing)
        (doc/special-form-doc content)
        (doc/thing-doc thing)))

    (cond
      (opts :eg)
      (ex/thing-examples content)
      #
      (opts :quiz)
      (qu/thing-quiz content))))

