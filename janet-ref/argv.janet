(defn parse-argv
  [argv]
  (def opts @{})
  (def rest @[])
  (def argc (length argv))
  #
  (when (> argc 1)
    (var i 1)
    (while (< i argc)
      (def arg (get argv i))
      (cond
        (get {"--bash-completion" true} arg)
        (put opts :bash-completion true)
        #
        (get {"--fish-completion" true} arg)
        (put opts :fish-completion true)
        #
        (get {"--zsh-completion" true} arg)
        (put opts :zsh-completion true)
        #
        (get {"--raw-all" true} arg)
        (put opts :raw-all true)
        #
        (get {"--doc" true "-d" true}
             arg)
        (put opts :doc true)
        #
        (get {"--eval" true "-e" true}
             arg)
        (put opts :eval true)
        #
        (get {"--format" true "-f" true}
             arg)
        (put opts :format true)
        #
        (get {"--grep" true "-g" true}
             arg)
        (put opts :grep true)
        #
        (get {"--help" true "-h" true}
             arg)
        (put opts :help true)
        #
        (get {"--indent" true "-i" true}
             arg)
        (put opts :indent true)
        #
        (get {"--macex1" true "-m" true}
             arg)
        (put opts :macex1 true)
        #
        (get {"--pprint" true "-p" true}
             arg)
        (put opts :pprint true)
        #
        (get {"--quiz" true "-q" true}
             arg)
        (put opts :quiz true)
        #
        (get {"--repl" true "-r" true}
             arg)
        (put opts :repl true)
        #
        (get {"--src" true "-s" true}
             arg)
        (put opts :src true)
        #
        (get {"--usage" true "-u" true}
             arg)
        (put opts :usage true)
        #
        (array/push rest arg))
      (++ i)))
  #
  [opts rest])

