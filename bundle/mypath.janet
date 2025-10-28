# adapted from spork/path
(def- w32-grammar
  ~{:main (sequence (opt (sequence (replace (capture :lead)
                                            ,(fn [& xs]
                                               [:lead (get xs 0)]))
                                   (any (set `\/`))))
                    (opt (capture :span))
                    (any (sequence :sep (capture :span)))
                    (opt (sequence :sep (constant ""))))
    :lead (sequence (opt (sequence :a `:`)) `\`)
    :span (some (if-not (set `\/`) 1))
    :sep (some (set `\/`))})

(def- posix-grammar
  ~{:main (sequence (opt (sequence (replace (capture :lead)
                                            ,(fn [& xs]
                                               [:lead (get xs 0)]))
                                   (any "/")))
                    (opt (capture :span))
                    (any (sequence :sep (capture :span)))
                    (opt (sequence :sep (constant ""))))
    :lead "/"
    :span (some (if-not "/" 1))
    :sep (some "/")})

(defn normalize
  [path &opt doze?]
  (default doze? (= :windows (os/which)))
  (def accum @[])
  (def parts
    (peg/match (if doze?
                 w32-grammar
                 posix-grammar)
               path))
  (var seen 0)
  (var lead nil)
  (each x parts
    (match x
      [:lead what] (set lead what)
      #
      "." nil
      #
      ".."
      (if (zero? seen)
        (array/push accum x)
        (do
          (-- seen)
          (array/pop accum)))
      #
      (do
        (++ seen)
        (array/push accum x))))
  (def ret
    (string (or lead "")
            (string/join accum (if doze? `\` "/"))))
  #
  (if (empty? ret)
    "."
    ret))

(defn join
  [& els]
  (def end (last els))
  (when (and (one? (length els))
             (not (string? end)))
    (error "when els only has a single element, it must be a string"))
  #
  (def [items sep]
    (cond
      (true? end)
      [(slice els 0 -2) `\`]
      #
      (false? end)
      [(slice els 0 -2) "/"]
      #
      [els (if (= :windows (os/which)) `\` "/")]))
  #
  (normalize (string/join items sep)))

(defn abspath?
  [path &opt doze?]
  (default doze? (= :windows (os/which)))
  (if doze?
    # https://stackoverflow.com/a/23968430
    # https://learn.microsoft.com/en-us/dotnet/standard/io/file-path-formats
    (truthy? (peg/match ~(sequence :a `:\`) path))
    (string/has-prefix? "/" path)))

(defn abspath
  [path &opt doze?]
  (default doze? (= :windows (os/which)))
  (if (abspath? path doze?)
    (normalize path doze?)
    # dynamic variable useful for testing
    (join (or (dyn :localpath-cwd) (os/cwd))
             path
             doze?)))

# XXX: not so tested
(defn basename
  [path &opt doze?]
  (def tos (= :windows (os/which)))
  (default doze? tos)
  (def revpath (string/reverse path))
  (def s (if tos `\` "/"))
  (def i (string/find s revpath))
  (if i
    (-> (string/slice revpath 0 i)
        string/reverse)
    path))

