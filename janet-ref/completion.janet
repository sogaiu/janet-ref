(def bash-completion
  ``
  _jref_things() {
      COMPREPLY=( $(compgen -W "$(jref --raw-all)" -- ${COMP_WORDS[COMP_CWORD]}) );
  }
  complete -F _jref_things jref
  ``)

(def fish-completion
  ``
  function __jref_complete_things
    if not test "$__jref_things"
      set -g __jref_things (jref --raw-all)
    end

    printf "%s\n" $__jref_things
  end

  complete -c jref -a "(__jref_complete_things)" -d 'things'
  ``)

(def zsh-completion
  ``
  #compdef jref

  _jref() {
      local matches=(`jref --raw-all`)
      compadd -a matches
  }

  _jref "$@"
  ``)

(defn maybe-handle-dump-completion
  [opts]
  # this makes use of the fact that print returns nil
  (not
    (cond
      (opts :bash-completion)
      (print bash-completion)
      #
      (opts :fish-completion)
      (print fish-completion)
      #
      (opts :zsh-completion)
      (print zsh-completion)
      #
      true)))

