# janet-ref (jref)

Multi-purpose [Janet](https://janet-lang.org) info tool for:

* doc and source lookups
* usages and quizzes
* data pretty-printing, code indenting and formatting
* quick evaluation and macro-expansion
* creating readable repl session / usage content

## Status

Adding:

* Usages and quizzes for more functions, macros, etc.

Preliminary Support:

* Functions, Macros, etc.
  * Doc lookup (--doc, -d)
  * Source lookup (--src, -s)
  * Usage (--usage, -u)
  * Quizzes (--quiz, -q)

* Data
  * Pretty-printing (--pprint, -p)

* Code
  * Formatting (--format, -f)
  * Indenting (--indent, -i)
  * Expression evaluation (--eval, -e)
  * Macro-expansion (--macex1, -m)

* Demo / Usage Creation
  * Tweaked Repl (--repl, -r)

## Invocation Examples

Take a quiz.

```
$ jref -q label
(label here
  (for i 0 2
    (when (pos? i)
      (______ here i))))
# =>
1

What value could work in the blank?
```

Show some usages.

```
$ jref -u mapcat
(mapcat string [1 2 3])
# =>
@["1" "2" "3"]

(mapcat scan-number ["2r111" "0x08" "8r11" "10"])
# =>
@[7 8 9 10]

(mapcat identity [["alice" 1] ["bob" 2] ["carol" 3]])
# =>
@["alice" 1 "bob" 2 "carol" 3]

(->> [[:a 1] [:b 2] [:c 3]]
     (mapcat identity)
     splice
     table)
# =>
@{:a 1 :b 2 :c 3}
```

Look up some docs.

```
$ jref -d var
special form

`(var name meta... value)`

`var` binds a value to a symbol.

The symbol can be substituted for the value in subsequent
expressions for the same result.

A binding made by `var` can be updated using `set`.

For further info, see:

  https://janet-lang.org/docs/specials.html
```

Pretty-print some data.

```
$ jref -p "{:a 1 :b {:x 8 :y 9}}"
{:a 1
 :b {:x 8
     :y 9}}
```

Format some code.

```
$ jref -f "(defn a [x] (+ x 1)) (print (a 2))"
(defn a
  [x]
  (+ x 1))

(print (a 2))
```

Expand a macro call.

```
$ jref -m "(each i [0 1 2] (when (pos? i) (break)))"
(do
  (def _0000c3
    [0 1 2])
  (var _0000c2
    (<function next> _0000c3 nil))
  (while (<function not=> nil _0000c2)
    (def i
      (<function in> _0000c3 _0000c2))
    (when (pos? i)
      (break))
    (set _0000c2
         (<function next> _0000c3 _0000c2))))
```

Evaluate some code.

```
$ jref -e "(> (length (all-bindings)) 500)"
true
```

Get basic help.

```
$ jref -h
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

  --env-vars                   show tweakable environment variables

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

The `ensure-tags` jpm task can perform this setup:

  `jpm run ensure-tags`

This should clone the janet source + some extra bits to create the
`TAGS` file.  Once cloning is complete, the TAGS file should get
created automatically.

The `TAGS` file should end up in the `janet` subdirectory.
```

## Credits

Significant portions of the code and documentation come from Janet,
spork, and the janet-lang.org website.  Thus the following license
applies to at least those portions.

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

