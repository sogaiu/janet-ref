########################################################################

(def tap-version 14)

(defn print-tap-version
  [n]
  (printf "TAP Version %d" n))

(defn indent
  [buf n]
  (when (not (pos? (length buf)))
    (break buf))
  #
  (def nl-spaces
    (buffer/push @"\n"
                 ;(map |(do $ " ")
                       (range 0 n))))
  (def indented
    (buffer/push (buffer/new-filled n (chr " "))
                 buf))
  # XXX: not so efficient, but good enough?
  (string/replace-all "\n"
                      nl-spaces
                      indented))

(comment

  (def src
    @``
     (source [0, 0] - [1, 0]
       (kwd_lit [0, 0] - [0, 8]))
     ``)

  (indent src 2)
  # =>
  ``
    (source [0, 0] - [1, 0]
      (kwd_lit [0, 0] - [0, 8]))
  ``

  )

########################################################################

(defn run-tests
  [input-dir expected-dir]
  (when (or (not (os/stat input-dir))
            (not (os/stat expected-dir)))
    (eprint "input and expected directories must both exist")
    (break nil))

  (def stats @[])

  (var i 0)

  (def tf (file/temp))

  (def actual @"")
  (def expected @"")

  (var last-end 0)

  (def src-paths
    (filter |(= :file
                (os/stat (string input-dir "/" $)
                         :mode))
            (os/dir input-dir)))

  # XXX: tappy doesn't seem to like this
  #(print-tap-version tap-version)

  (var result nil)

  (printf "1..%d" (length src-paths))

  (each fp src-paths

    (buffer/clear actual)
    (buffer/clear expected)

    # result may be set to return value of deep= below
    # which is true or false - nil means test skipped
    (set result nil)

    (def input-fp
      (string input-dir "/" fp))

    (def ext-pos
      (last (string/find-all ".txt" fp)))

    (def name-no-ext
      (string/slice fp 0 ext-pos))

    (def expected-fp
      (string expected-dir "/" name-no-ext ".txt"))

    # only makes sense to test if there is an expected value
    (when (os/stat expected-fp)

      (def command
        (->> (slurp input-fp)
             string/trim
             (string/split " ")))

      # XXX: somehow this keeps appending to tf, ignoring where the current
      #      file position is (as reported by file/tell)
      (def ret
        (os/execute command :p {:out tf}))

      (file/flush tf)

      (def pos
        (file/tell tf))

      (def n-bytes
        (- pos last-end))

      (file/seek tf :set last-end)

      (set last-end pos)

      (file/read tf n-bytes actual)

      (def ef (file/open expected-fp))
      (file/read ef :all expected)
      (file/close ef)

      (set result
        (deep= actual expected)))

    (cond
      (true? result)
      (do
        (printf "ok %d" (inc i))
        (array/push stats [i :ok]))
      #
      (false? result)
      (do
        (printf "not ok %d - %s"
                (inc i) input-fp)
        (printf "  ---")
        (printf "  found:")
        (printf "%s" (indent (string/trim actual) 4))
        (printf "  wanted:")
        (printf "%s" (indent (string/trim expected) 4))
        (printf "  ...")
        (array/push stats [i :not-ok]))
      #
      (nil? result)
      (do
        (printf "not ok %d - %s # SKIP"
                (inc i) input-fp)
        (array/push stats [i :skip]))
      # defensive
      (eprintf "unexpected result: %M" result))

    (++ i))

  (file/close tf)

  [stats i])

(defn main
  [& args]
  (def input-files-dir
    (get args 1))
  (def expected-files-dir
    (get args 2))
  #
  (run-tests input-files-dir expected-files-dir))
