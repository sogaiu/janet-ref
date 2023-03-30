# janet-ref (jref)

Tool for doc lookups, examples, and quizzes of
[Janet](https://janet-lang.org) info.

# Usages Examples

```
$ jref -h
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
```
