# produce index file (tags or TAGS) for janet source repository

# this handles janet -> janet and janet -> c lookups
# for c -> c lookups, consider using ccls / clangd with lsp-mode / eglot

# 1. requires universal ctags aka u-ctags
# 2. run from janet source repository root
#
# emacs users, to get TAGS file support, do:
#
#  $ export IJS_OUTPUT_FORMAT=etags
#
# before running this script

(def usage
  ``
  Usage: idk-janet

  Generate `tags` / `TAGS` file for Janet source code

  Invoke in root of janet source repository directory.

  By default `tags` file is generated.

  To create `TAGS` instead (e.g. for use with emacs),
  set the `IJS_OUTPUT_FORMAT` environment variable to have the
  value `etags`, before invoking `idk-janet`.
  ``)

###########################################################################

(defn ctags/u-ctags-bin-name
  []
  # XXX: on windows may be ctags-universal.exe is never encountered...
  (when-let [path-env (os/getenv "PATH")]
    (def is-win (= :windows (os/which)))
    (var env-sep ":")
    (var path-sep "/")
    (var exe-suffix "")
    (when is-win
      (set env-sep ";")
      (set path-sep "\\")
      (set exe-suffix ".exe"))
    (var bin-name "ctags")
    (each path-dir (string/split env-sep path-env)
      (when (= :file
               (os/stat (string path-dir path-sep
                                "ctags-universal" exe-suffix)
                        :mode))
        (set bin-name "ctags-universal")
        (break)))
    (if is-win
      (string bin-name exe-suffix)
      bin-name)))

(comment

  (let [bin-name (ctags/u-ctags-bin-name)]
    (or (= bin-name "ctags")
        (= bin-name "ctags-universal")
        (= bin-name "ctags.exe")))
  # =>
  true

  )

###########################################################################

(defn ctags/make-warning
  [ctags-bin]
  (string ctags-bin
          ": Notice: No options will be read from files or environment"))

###########################################################################

(defn ctags/u-ctags
  [ctags-bin args out-buf err-buf]
  (let [proc (os/spawn [ctags-bin ;args]
                       :px
                       {:out :pipe
                        :err :pipe})]
    (ev/gather
      (ev/read (proc :out) :all out-buf)
      (ev/read (proc :err) :all err-buf))
    (os/proc-wait proc)
    (os/proc-close proc)))

###########################################################################

(defn ctags/for-most-args
  [opts]
  [# avoid being affected by local configuration
   `--options=NONE` # XXX: noisy
   #`--quiet=yes`   # XXX: ineffective for above noise
   (string `--output-format=` (opts :output-format))
   `--sort=no`
   `--recurse=yes`
   `--langdef=custom`
   `--langmap=custom:.c`
   `--languages=custom`
   # pseudo tags not meaningful for etags output -- ctags-client-tools(7)
   `--extras=+p`
   (string `--pseudo-tags=`
           `{TAG_OUTPUT_EXCMD}`
           `{TAG_OUTPUT_FILESEP}`
           `{TAG_OUTPUT_MODE}`
           `{TAG_PATTERN_LENGTH_LIMIT}`
           `{TAG_PROC_CWD}`
           `{TAG_PROGRAM_AUTHOR}`
           `{TAG_PROGRAM_NAME}`
           `{TAG_PROGRAM_URL}`
           `{TAG_PROGRAM_VERSION}`
           `{TAG_FILE_FORMAT}`
           #`{TAG_FILE_SORTED}` # code handles this below
           )
   # things to exclude
   # XXX: not sure whether this is necessary
   #`--exclude=src/core/wrap.c`
   # janet's c source code
   ;[# janet function name
     (string `--mline-regex-custom=`
             `/^[ \t]*`
             `JANET(_CORE)?_FN\(`
             `[ \t]*`
             `([^0-9:#][^:#]*)`
             `[ \t]*,`
             `[^"\n]*\n*[^"\n]*`
             `"\(([^ \)]+)/` # target
             `\3/`
             `f/`
             `{mgroup=2}`)
     # janet identifier name
     # XXX: should account for newlines?
     (string `--mline-regex-custom=`
             `/^[ \t]*`
             `JANET(_CORE)?_DEF\(`
             `[ \t]*`
             `([^:#][^0-9:#]*)`
             `[ \t]*`
             `,`
             `[ \t]*`
             `"([^"]+)"/` # target
             `\3/`
             `f/`
             `{mgroup=2}`)
     # core/channel, core/file, core/parser, etc.
     (string `--mline-regex-custom=`
             `/^[ \t]*`
             `(static)?`
             `[ \t]*`
             `const`
             `[ \t]*`
             `JanetAbstractType`
             `[ \t]*`
             `[^0-9:#][^:#]*`
             `[ \t]*`
             `=`
             `[ \t]*`
             `.` # XXX: matching a single open curly brace
             `[ \t]*`
             `\n`
             `[ \t]*`
             `"([^"]+)"/` # target
             `\2/`
             `f/`
             `{mgroup=2}`)
     ]
   # janet source code
   ;[(string `--langdef=Janet`)
     (string `--langmap=Janet:.janet`)
     # XXX: not accounting for newlines...
     (string `--regex-janet=`
             `/^\([ \t]*def[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `d,def/`)
     (string `--regex-janet=`
             `/^\([ \t]*defglobal[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `g,defglobal/`)
     (string `--regex-janet=`
             `/^\([ \t]*defmacro[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `m,macro/`)
     (string `--regex-janet=`
             `/^\([ \t]*defn[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `n,defn/`)
     (string `--regex-janet=`
             `/^\([ \t]*defdyn[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `y,defdyn/`)
     (string `--regex-janet=`
             `/^\([ \t]*var[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `v,var/`)
     (string `--regex-janet=`
             `/^\([ \t]*varfn[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `r,varfun/`)
     (string `--regex-janet=`
             `/^\([ \t]*varglobal[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `G,varglobal/`)
     # private things
     (string `--regex-janet=`
             `/^\([ \t]*def-[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `D,privatedef/`)
     (string `--regex-janet=`
             `/^\([ \t]*defmacro-[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `M,privatedefmacro/`)
     (string `--regex-janet=`
             `/^\([ \t]*defn-[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `N,privatedefn/`)
     (string `--regex-janet=`
             `/^\([ \t]*var-[ \t]+([^0-9:#][^ \t\[{(]+)/`
             `\1/`
             `V,privatevar/`)
     ]
   `--languages=custom,janet`
   `-f` `-`
   `src`
   #`test` # XXX: destructuring def and var not handled correctly
   #`examples`
   #`tools` # XXX: destructuring def and var not handled correctly
  ])

(defn ctags/for-specials-args
  [opts]
  [# avoid being affected by local configuration
   `--options=NONE` # XXX: noisy
   (string `--output-format=` (opts :output-format))
   `--sort=no`
   `--langdef=custom`
   `--langmap=custom:.c`
   `--languages=custom`
   # break, def, do, fn, if, quasiquote, quote, splice, unquote,
   # upscope, var, while
   `--regex-custom=/^static JanetSlot janetc_([a-z]+)\(/\1/D,def/`
   # set
   `--regex-custom=/^static JanetSlot janetc_varset\(/set/D,def/`
   `-f` `-`
   `src/core/specials.c`
  ])

(defn ctags/for-corelib-args
  [opts]
  [# avoid being affected by local configuration
   `--options=NONE` # XXX: noisy
   (string `--output-format=` (opts :output-format))
   `--sort=no`
   `--langdef=custom`
   `--langmap=custom:.c`
   `--languages=custom`
   # apply
   `--regex-custom=/^static void make_apply/apply/D,def/`
   # mod, %, cmp, next, propagate, debug, error, yield, cancel, resume,
   # in, get, put, length, bnot
   (string `--mline-regex-custom=`
           `/^[ \t]+`
           `janet_quick_asm\(`
           `[ \t]*`
           `[a-zA-Z0-9_]+`
           `[ \t]*`
           `,`
           `[ \t]*`
           `[a-zA-Z0-9_]+`
           `[ \t]*`
           `,`
           `[ \t]*`
           `\n?`
           `[ \t]*`
           `"([^"]+)"/`
           `\1/`
           `D,def/`
           `{mgroup=0}`)
   # +, -, *, /, band, bor, bxor, blshift, brshift, brunshift
   (string `--mline-regex-custom=`
           `/^[ \t]+`
           `templatize_varop\(`
           `[ \t]*`
           `[a-zA-Z0-9_]+`
           `[ \t]*`
           `,`
           `[ \t]*`
           `[a-zA-Z0-9_]+`
           `[ \t]*`
           `,`
           `[ \t]*`
           `\n?`
           `[ \t]*`
           `"([^"]+)"/`
           `\1/`
           `D,def/`
           `{mgroup=0}`)
   # >, <, >=, <=, =, not=
   (string `--mline-regex-custom=`
           `/^[ \t]+`
           `templatize_comparator\(`
           `[ \t]*`
           `[a-zA-Z0-9_]+`
           `[ \t]*`
           `,`
           `[ \t]*`
           `[a-zA-Z0-9_]+`
           `[ \t]*`
           `,`
           `[ \t]*`
           `\n?`
           `[ \t]*`
           `"([^"]+)"/`
           `\1/`
           `D,def/`
           `{mgroup=0}`)
   # janet/version, janet/build, janet/config-bits
   (string `--regex-custom=`
           `/^[ \t]+`
           `janet_def\(`
           `[ \t]*`
           `[a-zA-Z0-9_]+`
           `[ \t]*`
           `,`
           `[ \t]*`
           `"([^"]+)"/`
           `\1/`
           `D,def/`)
   `-f` `-`
   `src/core/corelib.c`
  ])

(defn ctags/for-math-args
  [opts]
  [# avoid being affected by local configuration
   `--options=NONE` # XXX: noisy
   (string `--output-format=` (opts :output-format))
   `--sort=no`
   `--langdef=custom`
   `--langmap=custom:.c`
   `--languages=custom`
   # acos, asin, atan, etc.
   (string `--regex-custom=`
           `/^JANET_DEFINE_MATHOP\(`
           `([a-z0-9]+),/`
           `math\/\1/`
           `D,def/`)
   # log-gamma, fabs, tgamma
   (string `--regex-custom=`
           `/^JANET_DEFINE_NAMED_MATHOP\(`
           `"`
           `([a-z0-9-]+)`
           `",/`
           `math\/\1/`
           `D,def/`)
   # atan2, pow, hypot, next
   (string `--regex-custom=`
           `/^JANET_DEFINE_MATH2OP\(`
           `[^"]+"\(`
           `([^ ]+)`
           ` /`
           `\1/`
           `D,def/`)
   `-f` `-`
   `src/core/math.c`
  ])

(defn in-janet-src-dir?
  []
  (and (os/stat "janet.1")
       (os/stat "src")))

###########################################################################

(defn main
  [& argv]

  (when (or (not (in-janet-src-dir?))
            (when-let [arg (get argv 1)]
              (= "--help" arg)))
    (print usage)
    (os/exit 0))

  (def opts
    @{:output-format "u-ctags"
      :file-extension ""})

  (when-let [fmt (os/getenv "IJS_OUTPUT_FORMAT")]
    (when (nil? (get {"etags" true "u-ctags" true}
                     fmt))
      (errorf "Unrecognized IJS_OUTPUT_FORMAT value: %s" fmt))
    (put opts :output-format fmt))

  (def out-format
    (opts :output-format))

  (when-let [file-ext (os/getenv "IJS_FILE_EXTENSION")]
    (put opts :file-extension file-ext))

  (def file-extension
    (opts :file-extension))

  (def tags-fname
    (case out-format
      "etags"
      (string "TAGS" file-extension)
      #
      "u-ctags"
      (string "tags" file-extension)
      #
      (errorf "Unrecognized output-format: %s" out-format)))

  # name of universal ctags binary
  (def ctags-bin (ctags/u-ctags-bin-name))

  (defn log-any-err
    [err-buf fname]
    (def ctags-warning (ctags/make-warning ctags-bin))
    (unless (or (empty? err-buf)
                # --options=NONE leads to this warning
                (= ctags-warning
                   (string/trim err-buf)))
      (eprintf "Unexpected standard error output from ctags, see: %s"
               fname)
      (spit fname err-buf)))

  (def out-buf @"")

  # most of janet's c source and .janet files can be handled with one
  # ctags invocation
  (def err-1-buf @"")

  (try
    (ctags/u-ctags ctags-bin (ctags/for-most-args opts)
                   out-buf err-1-buf)
    ([err]
      (eprintf "Error invoking ctags for general coverage: %p" err)
      (os/exit 1)))

  (log-any-err err-1-buf "tags-1-error")

  # make another pass over src/core/specials.c
  (def err-2-buf @"")

  (try
    (ctags/u-ctags ctags-bin (ctags/for-specials-args opts)
                   out-buf err-2-buf)
    ([err]
      (eprintf "Error invoking ctags for specials.c: %p" err)
      (os/exit 1)))

  (log-any-err err-2-buf "tags-2-error")

  # make another pass over src/core/corelib.c
  (def err-3-buf @"")

  (try
    (ctags/u-ctags ctags-bin (ctags/for-corelib-args opts)
                   out-buf err-3-buf)
    ([err]
      (eprintf "Error invoking ctags for corelib.c: %p" err)
      (os/exit 1)))

  (log-any-err err-3-buf "tags-3-error")

  # pick up some things from src/core/math.c
  (def err-4-buf @"")

  (try
    (ctags/u-ctags ctags-bin (ctags/for-math-args opts)
                   out-buf err-4-buf)
    ([err]
      (eprintf "Error invoking ctags for math.c: %p" err)
      (os/exit 1)))

  (log-any-err err-4-buf "tags-4-error")

  # lines should only be sorted for u-ctags
  (def out-lines
    (let [lines (string/split "\n" out-buf)]
      (if (= out-format "u-ctags")
        (sort lines)
        lines)))

  # write the index (u-ctags -> tags, etags -> TAGS)
  (with [tf (file/open tags-fname :w)]
    # XXX: yuck -- if a toggling sorting option is provided, following code
    #      probably needs to change
    (when (= out-format "u-ctags")
      (file/write tf
                  (string "!_TAG_FILE_SORTED\t"
                          "1\t"
                          "/0=unsorted, 1=sorted, 2=foldcase/\n")))
    (each line out-lines
      (when (not= line "") # XXX: not nice to be checking so many times
        (file/write tf line)
        (when (not (or (string/has-suffix? "\r" line)
                       (string/has-suffix? "\n" line)))
          (file/write tf "\n"))))
    (file/flush tf))

  (os/exit 0))
