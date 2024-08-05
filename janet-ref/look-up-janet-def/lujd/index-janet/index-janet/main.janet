(import ./index-c :as ic)
(import ./index-j2c :as ij2c)
(import ./index-janet :as ij)
(import ./tags)

(def usage
  ``
  Usage: idx-janet

  Generate `tags` / `TAGS` file for Janet source code

  Invoke in root of janet source repository directory.

  This handles lookups for:

  * Janet -> Janet  (e.g. defn in boot.janet)
  * Janet -> C      (e.g. set in specials.c)

  For C -> C lookups, consider an LSP server for C such as ccls or
  clangd.

  By default a `tags` file is generated.

  To create a `TAGS` instead (e.g. for use with emacs), set the
  `IJ_OUTPUT_FORMAT` environment variable to have the value `etags`,
  before invoking `idx-janet`.

  For example, on a *nix machine with certain shells, this could be
  something like:

    export IJ_OUTPUT_FORMAT=etags

  Other systems and/or shells may have a different way of setting
  environment variables.
  ``)

########################################################################

(defn in-janet-src-dir?
  []
  (and (os/stat "janet.1")
       (os/stat "src")))

########################################################################

(defn main
  [& argv]

  (when (or (not (in-janet-src-dir?))
            (when-let [arg (get argv 1)]
              (= "--help" arg)))
    (print usage)
    (break 0))

  (def opts
    @{:output-format "u-ctags"
      :file-extension ""})

  (when (os/getenv "IJ_C2C")
    (setdyn :ij-c2c true))

  (when (os/getenv "IJ_DEBUG")
    (setdyn :ij-debug true))

  (when-let [fmt (os/getenv "IJ_OUTPUT_FORMAT")]
    (when (nil? (get {"etags" true "u-ctags" true}
                     fmt))
      (errorf "Unrecognized IJ_OUTPUT_FORMAT value: %s" fmt))
    (put opts :output-format fmt))

  (def out-format
    (opts :output-format))

  (when-let [file-ext (os/getenv "IJ_FILE_EXTENSION")]
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

  (def out-buf @"")

  # XXX: eventually index other janet files in source tree too?
  #      only seemed to ever index boot.janet

  # XXX: hack to capture all ids in an array
  (setdyn :all-ids @[])

  (ij/index-janet-boot! out-buf)

  (each name (os/dir "src/core/")
    (def path (string "src/core/" name))
    (def src (slurp path))
    (cond
      (= "io.c" name)
      (ij2c/index-janet-core-def-c! src path out-buf)
      #
      (= "math.c" name)
      (do
        (ij2c/index-math-c! src path out-buf)
        (ij2c/index-janet-core-def-c! src path out-buf))
      #
      (= "specials.c" name)
      (ij2c/index-specials-c! src path out-buf)
      #
      (= "corelib.c" name)
      (ij2c/index-corelib-c! src path out-buf))
    #
    (try
      (ij2c/index-generic-c! src path out-buf)
      ([e]
        (eprintf "%s %s" e path)))
    #
    (when (dyn :ij-c2c)
      (try
        (ic/index-c! src path out-buf)
        ([e]
          (eprintf "%s %s" e path)))))

  (when (dyn :ij-c2c)
    (def path
      "src/include/janet.h")
    (def src
      (slurp path))
    (try
      (ic/index-c! src path out-buf)
      ([e]
        (eprintf "%s %s" e path))))

  (def out-lines
    (if (= out-format "u-ctags")
      (tags/etags-to-tags out-buf)
      (string/split "\n" out-buf)))

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
    (file/flush tf)))

