(def bash-completion
  ``
  _lujd_ids() {
      COMPREPLY=( $(compgen -W "$(lujd --raw-all)" -- ${COMP_WORDS[COMP_CWORD]}) );
  }
  complete -F _lujd_ids lujd
  ``)

(def fish-completion
  ``
  function __lujd_complete_ids
    if not test "$__lujd_ids"
      set -g __lujd_ids (lujd --raw-all)
    end

    printf "%s\n" $__lujd_ids
  end

  complete -c lujd -a "(__lujd_complete_ids)" -d 'ids'
  ``)

(def zsh-completion
  ``
  #compdef lujd

  _lujd() {
      local matches=(`lujd --raw-all`)
      compadd -a matches
  }

  _lujd "$@"
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

