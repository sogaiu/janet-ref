(def docstring
  ``
  Environment Variables Related to jref

  jref's behavior is influenced by a number of environment variables.

  At the moment, what can be affected includes:

  * Color
  * Editor (for displaying source)
  * Janet Source (for displaying source)
  * Source Searching

  N.B. It's not so clear which ones will stick around, but if you
  find any useful, mentioning this might affect whether certain
  ones survive.

  Color
  -----

  jref does not directly apply color to any of its output but instead
  allows one to specify a separate program to do so.

  JREF_COLORIZER - valid values include:

  * bat
  * pygmentize
  * rougify

  If set appropriately, jref will try to send certain output through
  the selected program with an aim toward coloring the output.

  JREF_COLORIZER_STYLE - valid values depend on what was selected
  for JREF_COLORIZER.

  If set appropriately, the theme / style used by the selected
  "colorizer" will be affected.

  Some examples include:

  * bat
    * dracula
    * gruvbox-dark
    * monokai-extended-origin
    * OneHalfDark

    `bat --list-themes` enumerates some options.

  * pygmentize
    * dracula
    * gruvbox-dark
    * monokai
    * one-dark
    * rrt

    `pygmentize -L styles` enumerates some options.

  * rougify
    * gruvbox
    * monokai
    * thankful_eyes

    `ls ~/src/rouge/lib/rouge/themes` enumerates some options
    (assuming rouge source code has been fetched and placed in a
    certain location).

  JREF_COLORIZER_FILENAME - valid values might be something like:

  * bat.bat
  * pygmentize.com

  If set appropriately, this is used in the invocation of the
  colorizer.  It primarily exists to support Windows where the file
  extension is not so easy for jref's author to determine (e.g. you
  might be using a shim or a .bat script to lauch a colorizer).  If
  you're using Windows and your colorizer's filename extension is not
  ".exe", setting this might help.


  Editor
  ------

  If configured appropriately, jref's `--src` option hands off
  displaying of source code to an editor.

  JREF_EDITOR - valid values include:

  * emacs
  * kak
  * nvim
  * subl
  * vim

  If set appropriately, the editor invoked by jref to display source
  code is affected, but see JREF_EDITOR_FILENAME below for a caveat.

  The value is also used to determine arguments passed to the editor
  in order to open a certain file at a particular line, but see
  JREF_EDITOR_OPEN_AT_FORMAT below for a caveat.

  Other values may work, but then JREF_EDITOR_OPEN_AT_FORMAT likely
  needs to be set too.

  JREF_EDITOR_OPEN_AT_FORMAT - valid value might be something like:

  * "+%d %s"
  * "%s:%d"

  It set appropriately, this overrides the arguments an editor uses to
  open a file at a particular line.  If your editor is already
  supported, you probably don't need to set this.

  You can try this if you have set JREF_EDITOR to something other than
  what was listed as a valid value in the JREF_EDITOR description
  above.  It's probably better to discuss support for an editor with
  jref's author though.

  JREF_EDITOR_FILENAME - valid values might be something like:

  * edit.com
  * emacs.bat

  If set appropriately, this is used in the invocation of the editor.
  It primarily exists to support Windows where the file extension is
  not so easy for jref's author to determine (e.g. you might be using
  a shim or a .bat script to lauch an editor).  If you're using
  Windows and your editor's filename extension is not ".exe", setting
  this might help.

  Janet Source
  ------------

  In order for jref's `--src` capability to function, an index of
  janet's source code needs to be created.  Also, in order to use the
  index, the source needs to be available.

  JREF_JANET_SRC_PATH - a valid value might be something like:

  * /home/user/src/janet
  * /Users/user/Desktop/janet

  If set appropriately, this is used when creating an index for
  janet's source code.  The path is also used when displaying a
  relevant source file.

  Source Searching
  ----------------

  There is some support for searching through a collection of janet
  source code via the `--grep` option.

  JREF_REPOS_PATH - a valid value might be something like:

  * /home/user/src/janet-repos
  * /Users/user/Desktop/janet-collection

  If set appropriately, this is used as a directory to search under.

  ``)
