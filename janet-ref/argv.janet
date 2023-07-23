(import ./vendor/argy-bargy :as ab)

(defn parse-argv
  [argv]
  (def usage @"")
  (def ret
    (with-dyns [:args argv
                # for turning off argy-bargy output
                :err @"" :out usage]
      (ab/parse-args
        (get argv 0)
        {:rules
         ["--help" {:kind :flag :short "h"
                    :help "show this output"}
          "---"
          "--doc" {:kind :flag :short "d"
                   :help "show doc"}
          "--quiz" {:kind :flag :short "q"
                    :help "show quiz question"}
          "--src" {:kind :flag :short "s"
                   :help "show source [1]"}
          "--usage" {:kind :flag :short "u"
                     :help "show usages"}
          "---"
          "--pprint" {:kind :flag :short "p"
                      :help "pretty-print data"}
          "---"
          "--format" {:kind :flag :short "f"
                      :help "format code"}
          "--indent" {:kind :flag :short "i"
                      :help "indent code"}
          "--eval" {:kind :flag :short "e"
                    :help "evaluate code"}
          "--macex1" {:kind :flag :short "m"
                      :help "macroexpand code"}
          "---"
          "--repl" {:kind :flag :short "r"
                    :help "run a repl"}
          "---"
          "--env-vars" {:kind :flag
                        :help "show tweakable environment vars"}
          "---"
          "--bash-completion" {:kind :flag
                               :help "output bash-completion bits"}
          "--fish-completion" {:kind :flag
                               :help "output fish-completion bits"}
          "--zsh-completion" {:kind :flag
                              :help "output zsh-completion bits"}
          "---"
          "--raw-all" {:kind :flag
                       :help "show all things to help completion"}
          "---"
          "--bindings" {:kind :flag}
          "---"
          "--grep" {:kind :flag :short "g"}
          "--todo" {:kind :flag :short "t"}
          "---"
          :thing {:value :string
                  :help "name of function, macro, special form, etc."}]
         :info
         {:about
          (string "View Janet information for things such as functions, "
                  "macros, special forms, etc.")
          :usages ["usage: jref [THING] [OPTION].."
                   "       jref [OPTION]... [THING]"]
          :rider
          ``
          With THING, but no options, show docs and usages.

          With the `-d` or `--doc` option, show docs for THING, or if none
          specified, for a randomly chosen one.

          With the `-q` or `--quiz` option, show quiz question for specified
          THING, or if none specified, for a randonly chosen one.

          With the `-s` or `--src` option, show source code for specified
          THING, or if none specified, for a randonly chosen one [1].

          With the `-u` or `--usage` option, show usages for specified THING,
          or if none specified, for a randomly chosen one.

          With no arguments, lists all things.

          Be careful to quote shortnames (e.g. *, ->, >, <-, etc.)
          appropriately so the shell doesn't process them in an undesired
          fashion.

          ---

          [1] For source code lookups to work, the Janet source code needs to
          be available locally and a suitable `TAGS` file needs to exist.

          The `ensure-tags` jpm task can perform this setup:

            `jpm run ensure-tags`

          This should clone the janet source + some extra bits to create the
          `TAGS` file.  Once cloning is complete, the TAGS file should get
          created automatically.

          The `TAGS` file should end up in the `janet` subdirectory.
          ``}})))
  (when-let [e (get ret :error?)]
    (eprintf "error parsing args: %p" e)
    (break [nil nil]))
  (def opts
    (->> (get ret :opts)
         pairs
         (map (fn [[k v]]
                [(keyword k) v]))
         from-pairs))
  (def rest
    (if-let [thing (get-in ret [:params :thing])]
      [thing]
      []))
  # XXX: argy-bargy won't save `--help` so need to add it
  (when (get ret :help?)
    (put opts :help true))
  #
  [opts rest usage])

