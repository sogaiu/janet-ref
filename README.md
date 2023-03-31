# janet-ref (jref)

Tool for doc lookups, examples, and quizzes of
[Janet](https://janet-lang.org) info.

## Status

Adding things :)

## Usages Examples

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

## Credits

Significant portions of the documentation come from Janet and the
janet-lang.org website.  Thus the following license applies to at
least those portions.

```
Copyright (c) 2019, 2020, 2021, 2022, 2023 Calvin Rose and contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

