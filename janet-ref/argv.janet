(import ./vendor/argy-bargy :as ab)

(defn parse-argv
  [argv]
  (def ret
    (with-dyns [:args argv
                # for turning off argy-bargy output
                :err @"" :out @""]
      (ab/parse-args
        {:rules
         ["--env-vars" {:kind :flag}
          "--bash-completion" {:kind :flag}
          "--fish-completion" {:kind :flag}
          "--zsh-completion" {:kind :flag}
          "--raw-all" {:kind :flag}
          "--bindings" {:kind :flag}
          #
          "--doc" {:kind :flag :short "d"}
          "--eval" {:kind :flag :short "e"}
          "--format" {:kind :flag :short "f"}
          "--grep" {:kind :flag :short "g"}
          "--help" {:kind :flag :short "h"}
          "--indent" {:kind :flag :short "i"}
          "--macex1" {:kind :flag :short "m"}
          "--pprint" {:kind :flag :short "p"}
          "--quiz" {:kind :flag :short "q"}
          "--repl" {:kind :flag :short "r"}
          "--src" {:kind :flag :short "s"}
          "--todo" {:kind :flag :short "t"}
          "--usage" {:kind :flag :short "u"}
          :thing {:value :string}]})))
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
  [opts rest])

