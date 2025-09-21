(import ./argv :as av)
(import ./completion :as compl)
(import ./dyns :as d)
(import ./index :as idx)
(import ./src :as src)

(def usage
  `````
  Usage: lujd identifier
         lujd [option]

  Jump to the definition of a Janet identifier.

    -c, --conf-help            show config help
    -h, --help                 show this output

    --bash-completion          output bash-completion bits
    --fish-completion          output fish-completion bits
    --zsh-completion           output zsh-completion bits
    --raw-all                  show all identifiers

  Look up the definition of `identifier`, a Janet
  identifier, and if found, open an editor to
  display the located definition [1].

  Be careful to quote shortnames (e.g. *, ->, >, <-,
  etc.) appropriately so the shell doesn't process them
  in an undesired fashion.

  ---

  [1] Lookups are performed via an index of the Janet
  source code.  The index (a file named `TAGS.lujd`) is
  built from a local copy of the Janet source code and
  placed in the same directory.

  `lujd` minimally expects the location of Janet source
  code to be available via a file (`~/.lujd.janet` for
  *nixes) and/or an environment variable.

  See output of `lujd -c` for more details.
  `````)

(def conf-help
  `````
  Configuration Help for lujd
  ---------------------------

  `lujd` requires some configuration information to be
  specified and this is done via a file (`.lujd.janet`)
  and/or environment variables.

  Janet Source Code Location (Required)
  -------------------------------------

  Lookups are performed via an index of the Janet
  source code.  The index (a file named `TAGS.lujd`) is
  built from a local copy of the Janet source code and
  placed in the same directory.

  The location of the source code can be specified via
  a configuration file or an environment variable.

  For the configuration file approach, create a file
  named `.lujd.janet` in your `HOME` / `USERPROFILE`
  directory.  The content should be something like:

  ```
  {:janet-src-path
   (string (os/getenv "HOME") "/src/janet")}
  ```

  That is, the file should end with a struct that has
  at least the key `:janet-src-path` and its
  associated value should evaluate to a full path to
  Janet source code.

  For the environment variable approach, set
  `LUJD_JANET_SRC_PATH` to a full path of a local
  copy of the Janet source code.

  Editor for Displaying Definitions (Optional)
  --------------------------------------------

  Located definitions are displayed via an editor.

  The default editor is `nvim`.  Other supported
  editors include: `emacs`, `hx`, `kak`, `subl`, and
  `vim`.

  A particular editor other than the default can be
  configured via a file (see info about `.lujd.janet`
  above) or via an environment variable.

  For the configuration file approach, in a file
  named `.lujd.janet` in your `HOME` / `USERPROFILE`
  directory, add an appropriate key-value pair to
  a struct which ends up as the last value to be
  evaluated in the file.

  The key should be `:editor` and the value should
  be one of: `emacs`, `hx`, `kak`, `nvim`, `subl`,
  or `vim`.

  An example `.lujd.janet` might look like:

  ```
  {:editor "emacs"
   :janet-src-path
   (string (os/getenv "HOME") "/src/janet")}
  ```

  For the environment variable approach,
  `LUJD_EDITOR` should be set to one of: `emacs`,
  `hx`, `kak`, `nvim`, `subl`, or `vim`.
  `````)

########################################################################

(defn main
  [& argv]

  (d/init-dyns)

  (def [opts rest errs]
    (av/parse-argv argv))

  (when (not (empty? errs))
    (each err errs
      (eprint "lujd: " err))
    (eprint "Try 'lujd -h' for usage text.")
    (os/exit 1))

  # usage
  (when (or (opts :help)
            (and (empty? opts) (empty? rest)))
    (print usage)
    (os/exit 0))

  (when (opts :conf-help)
    (print conf-help)
    (os/exit 0))

  # possibly handle dumping completion bits
  (when (compl/maybe-handle-dump-completion opts)
    (os/exit 0))

  (def j-src-path (dyn :lujd-janet-src-path))
  (when (or (nil? j-src-path)
            (not= :directory (os/stat j-src-path :mode)))
    (eprint "Failed to find Janet source directory.")
    (eprint "Please set the env var LUJD_JANET_SRC_PATH to a")
    (eprint "full path of Janet source or arrange for an")
    (eprint "appropriate config file.  Please see the program")
    (eprint "usage text for details.")
    (os/exit 1))

  (def file-ext ".lujd")
  (def tags-fname (string "TAGS" file-ext))
  (def etags-path (string j-src-path "/" tags-fname))

  # help completion by showing a raw list of relevant names
  (when (opts :raw-all)
    # normal printing in the `--raw-all` situation is awkward because:
    # 1. output during completion is intermingled (hence confusing)
    # 2. seems to lead to bash permission errors (unknown why)
    (defn deprintf [msg & args]
      (when (os/getenv "VERBOSE") (eprintf msg ;args)))
    (defn dprintf [msg & args]
      (when (os/getenv "VERBOSE") (printf msg ;args)))

    (def cache-fname ".lujd.jdn")
    (def cache-path (string j-src-path "/" cache-fname))
    (when (or (not (os/stat cache-path))
              (not (idx/file-newest? cache-path j-src-path)))
      (deprintf "Cache file might be stale or failed to find it in: %s"
                j-src-path)
      (deprintf "Trying to create fresh cache file at: %s" cache-path)
      (idx/build-index j-src-path file-ext)
      (when (not (os/stat etags-path))
        (eprintf "Failed to create index file at: %s" etags-path)
        (os/exit 1))
      (dprintf "Created index file at: `%s`" etags-path)
      # idx/build-index should cause (dyn :all-ids) to be populated
      (when (not (dyn :all-ids))
        (eprintf "Failed to determine janet identifiers, aborting")
        (os/exit 1))
      #
      (when (not (idx/all-ids-valid? (dyn :all-ids)))
        (eprintf "Expected array of strings, but found: %n"
                 (dyn :all-ids))
        (os/exit 1))
      #
      (spit cache-path (string/format "%j" (dyn :all-ids)))
      (when (not (os/stat cache-path))
        (eprintf "Failed to create cache file at: %s" cache-path)
        (os/exit 1))
      #
      (dprintf "Created cache file at: `%s`" cache-path))
    #
    (when (not (dyn :all-ids))
      (def result
        (try
          (parse (slurp cache-path))
          ([e]
            (eprintf "Failed to read in cache file at: %s" cache-path)
            (eprint e)
            (os/exit 1))))
      #
      (when (not (idx/all-ids-valid? result))
        (eprintf "Expected array of strings, but found: %n" result)
        (os/exit 1))
      #
      (setdyn :all-ids result))
    #
    (each id (dyn :all-ids)
      (print id))
    (os/exit 0))

  # not expecting this to happen
  (when (empty? rest)
    (eprintf "Expected an identifier but found none")
    (os/exit 1))

  (when (or (not (os/stat etags-path))
            (not (idx/file-newest? etags-path j-src-path)))
    (eprintf "Index file might be stale or failed to find it in: %s"
             j-src-path)
    (eprintf "Trying to create fresh index file at: %s" etags-path)
    (idx/build-index j-src-path file-ext)
    (when (not (os/stat etags-path))
      (eprintf "Failed to create index file at: %s" etags-path)
      (os/exit 1))
    (printf "Created index file at: `%s`" etags-path))

  (def etags-content
    (try
      (slurp etags-path)
      ([e]
        (eprintf "Failed to read index file at: %s" etags-path)
        (os/exit 1))))

  (def thing (first rest))

  (src/definition thing etags-content j-src-path))
