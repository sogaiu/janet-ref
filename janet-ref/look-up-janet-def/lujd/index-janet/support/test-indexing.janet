# testing generated index files
#
# * this code is run via `jpm run test-indexing` (see project.janet)
#
# * the code will attempt to:
#   * clone / pull the janet source repository,
#   * check out various commits,
#   * generate index files, and
#   * attempt to check the generated content
#
# * it only supports checking tags files atm (not TAGS)

(defn main
  [& argv]
  # XXX
  (setdyn :debug true)
  (def indexing-script-path
    # the script path is relative to the `janet` subdir of the root dir
    # of this project because the script is invoked from inside the
    # `janet` subdir
    (string "../idx-janet"))
  (def repo-dir-name "janet")
  (def repo-url "https://github.com/janet-lang/janet")
  (def dflt-branch "master")
  # ensure recent janet source repository exists
  (if (= :directory
         (os/stat repo-dir-name :mode))
    (do
      (os/cd repo-dir-name)
      (when (dyn :debug) (printf "** checking out: %s" dflt-branch))
      (os/execute ["git" "checkout" dflt-branch] :px)
      (when (dyn :debug) (print "** pulling with tags"))
      # --tags needed to update tags
      (os/execute ["git" "pull" "--tags"] :px))
    (do
      (when (dyn :debug) (printf "** cloning: %s" repo-url))
      (os/execute ["git" "clone" repo-url] :px)
      (os/cd repo-dir-name)))
  (defer (os/execute ["git" "checkout" dflt-branch] :px)
    # test against multiple commits
    (each commit-ish
      [
       dflt-branch
       "v1.27.0"
       "v1.26.0"
       "v1.25.0" "v1.25.1"
       "v1.24.0"
       "v1.23.0"
       "v1.22.0"
       "v1.21.0" "v1.21.1" "v1.21.2"
       "v1.20.0"
       "v1.19.2" "v1.19.1" "v1.19.0"
       "v1.18.1" "v1.18.0"
       "v1.17.2" "v1.17.1" "v1.17.0"
       "v1.16.1" "v1.16.0"
       "v1.15.5" "v1.15.4" "v1.15.3" "v1.15.2" "v1.15.1" "v1.15.0"
       "v1.14.2" "v1.14.1"
       "v1.13.1" "v1.13.0"
       "v1.12.2" "v1.12.1" "v1.12.0"
       "v1.11.3" "v1.11.2" "v1.11.1" "v1.11.0"
       "v1.10.1" "v1.10.0"
       "v1.9.1" "v1.9.0"
       "v1.8.1" "v1.8.0"
       "v1.7.0"
       "v1.6.0"
       "v1.5.1" "v1.5.0"
       "v1.4.0"
       "v1.3.1" "v1.3.0"
       "v1.2.0"
       "v1.1.0"
       "v1.0.0"
       ]
      # checkout a commit
      (when (dyn :debug) (printf "** checking out: %s" commit-ish))
      (os/execute ["git" "checkout" commit-ish] :px)
      # create an index file
      (when (dyn :debug) (print "** indexing..."))
      (os/execute ["janet" indexing-script-path] :px)
      # the test consists of checking that the index file contains
      # certain entries.  `items` represents what to check for.
      # some entries won't exist before some commit though because
      # they wouldn't have been added to code yet.
      (def items
        {# key is beginning of tag line
         # value is a commit beyond (inclusive) which key should be found
         "run-context\tsrc/boot/boot.janet"
         "d66f8333c1d0324f43ec59ad4b66a88d52ec8f4b"
         #
         "core/peg\tsrc/core/peg.c"
         "d66f8333c1d0324f43ec59ad4b66a88d52ec8f4b"
         #
         "ev/read\tsrc/core/ev.c"
         "7e5f2264806c41a02d1117b4ddff009f74af560a"
         #
         "break\tsrc/core/specials.c"
         "4a111b38b19d67692348f606f4b734ce0700127d"
         #
         "apply\tsrc/core/corelib.c"
         "c8ef2a0d8819424e241dda4ee8681044554dd332"
         #
         "mod\tsrc/core/corelib.c"
         "28d41039b8ca18d8d0c023c4615a580b40fd3333"
         #
         "+\tsrc/core/corelib.c"
         "fcbd24cedc187fda51c35e8618fc8e627b83b8fc"
         #
         ">\tsrc/core/corelib.c"
         "fcbd24cedc187fda51c35e8618fc8e627b83b8fc"
         #
         "janet/version\tsrc/core/corelib.c"
         "4e4dd3116409e6e90cf73d0d9e387b2862994bd9"
         })
      # check the content of the index file
      (var cnt 0)
      (with [tf (file/open "tags")]
        (eachp [tag-line-prefix commit] items
          (def line @"")
          (var found nil)
          # don't check if the code doesn't exist yet
          (when (zero? (os/execute ["git" "merge-base" "--is-ancestor"
                                    commit commit-ish]
                                   :p))
            (while (file/read tf :line line)
              (when (string/has-prefix? tag-line-prefix line)
                (set found true)
                (++ cnt)
                (break))
              (buffer/clear line))
            (when (not found)
              (errorf "Failed to find: %s" tag-line-prefix))
            (file/seek tf :set 0))))
      # report number of located items (getting here means tests passed)
      (printf "Found all relevant %d items." cnt))))
