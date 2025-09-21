# index-janet

Generate `tags` / `TAGS` files for Janet's source code.

The index files provide lookups for Janet identifiers:

* Janet -> Janet (e.g. `if-let`)
* Janet -> C (e.g. `length` or `def`)

## Setup

```
git clone https:/github.com/sogaiu/index-janet
cd index-janet
jpm install
```

This should install a script named `idx-janet`.

## Usage

Assuming Janet source code lives in `~/src/janet`, to
generate `tags`:

```
cd ~/src/janet
idx-janet
```

This should produce a `tags` file, typically used by vim / neovim.

For `TAGS` (emacs):

```
cd ~/src/janet
IJ_OUTPUT_FORMAT=etags idx-janet
```

This should produce a `TAGS` file, typically used by emacs.

