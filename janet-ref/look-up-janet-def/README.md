# look-up-janet-def (lujd)

Look up a definition for a Janet identifier [1] via a command line
program and display the results in an editor.

![Invoking lujd](invoking-lujd-with-net-server-id.png?raw=true "Invoking lujd")

![Viewing definition](net-server-def-in-nvim.png?raw=true "Viewing definition")

## Installation and Setup

### Getting the Bits

Quick:

```
jpm install https://github.com/sogaiu/look-up-janet-def
```

Manual:

```
git clone https://github.com/sogaiu/look-up-janet-def
cd look-up-janet-def
jpm install
```

In either case, success should lead to the command `lujd` being
available on `PATH` and a `lujd` directory under `JANET_PATH`.

Ensure you have a local copy of the [Janet source
code](https://github.com/janet-lang/janet).  If you store your source
under `~/src`, you might arrange for it like this:

```
cd ~/src
git clone https://github.com/janet-lang/janet
```

### Configuration

#### Location of Janet Source Code

Create a file named `.lujd.janet` that lives under `$HOME` (or if on
Windows, under `$USERPROFILE`) and put something like the following in
it:

```janet
{
 :janet-src-path (string (os/getenv "HOME") "/src/janet")
}
```

The file `.lujd.janet` will be evaluated and the last value it returns
should be a struct with at least the key `:janet-src-path` and an
associated value that is the full path to a local copy of the Janet
source code.

If you don't want to make a configuration file, you can instead set
the environment variable `LUJD_JANET_SRC_PATH` to have the full path
to a local copy of the Janet source code as a value.

#### Specifying an Editor

Supported editors include:

* emacs
* hx
* kak
* nvim
* subl
* vim

Note that these are typical executable names on POSIX systems for the
editors in question.

The default is `nvim`, but a different editor can be specified via the
aforementioned configuration file `.lujd.janet`.  For example, to
specify `emacs` instead:

```janet
{
 :editor "emacs"
 :janet-src-path (string (os/getenv "HOME") "/src/janet")
}
```

If you don't want to make a configuration file, you can instead set
the environment variable `LUJD_EDITOR` to one of the aforementioned
supported editors.  Note that on Windows, do not include the `.exe` or
other file extension as part of the string specifying the editor.

## Usage

To look up an identifier (e.g. `defn`), invoke:

```
$ lujd defn
```

This should open the default editor (or editor of choice) with it
displaying the definition of `defn`.

Usage text can be seen via:

```
$ lujd -h
```

## Footnotes

[1] "Janet identifier" here refers to an identifier that is usable
from within a Janet program (i.e. a symbol), but that is defined in
the source code for the Janet programming language.  This includes
identifiers that have C definitions such as special forms (e.g.
`def`, `if`, etc.).

However, it does not include C identifiers (e.g. `run_vm`,
`janet_loop`, etc.).  Further, it hasn't been made to work with Janet
projects, i.e. it only works on identifiers that are part of the Janet
programming language itself.
