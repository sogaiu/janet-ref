# copy-modify of Janet's boot.janet

(import ./format/data :as data)

# conditional compilation for reduced os
(def- getenv-alias (if-let [entry (in root-env 'os/getenv)] (entry :value) (fn [&])))

(defn- run-main
  [env subargs arg]
  (when-let [entry (in env 'main)
             main (or (get entry :value) (in (get entry :ref) 0))]
    (def guard (if (get env :debug) :ydt :y))
    (defn wrap-main [&]
      (main ;subargs))
    (def f (fiber/new wrap-main guard))
    (fiber/setenv f env)
    (var res nil)
    (while (fiber/can-resume? f)
      (set res (resume f res))
      (when (not= :dead (fiber/status f))
        ((debugger-on-status env) f res)))))

# XXX: not so clear this needs to be out here
(defdyn *getprompt*
  "Function to be used as getprompt function in the repl.")

(defn cli-main
  `Entrance for the Janet CLI tool. Call this function with the command line
  arguments as an array or tuple of strings to invoke the CLI interface.`
  [args]

  (setdyn *args* args)

  (var should-repl false)
  (var no-file true)
  (var quiet false)
  (var raw-stdin false)
  (var handleopts true)
  (var exit-on-error true)
  (var colorize true)
  (var debug-flag false)
  (var compile-only false)
  (var warn-level nil)
  (var error-level nil)
  (var expect-image false)
  # XXX
  (var getprompt
    (fn [p] "")
#    (fn [p]
#      (def [line] (parser/where p))
#      (string "repl:" line ":" (parser/state p :delimiters) "> "))
    )

  (if-let [jp (getenv-alias "JANET_PATH")] (setdyn *syspath* jp))
  (if-let [jprofile (getenv-alias "JANET_PROFILE")] (setdyn *profilepath* jprofile))

  (defn- get-lint-level
    [i]
    (def x (in args (+ i 1)))
    (or (scan-number x) (keyword x)))

  # Flag handlers
  (def handlers
    {"h" (fn [&]
           (print "usage: " (dyn *executable* "janet") " [options] script args...")
           (print
             ```
             Options are:
               -h : Show this help
               -v : Print the version string
               -s : Use raw stdin instead of getline like functionality
               -e code : Execute a string of janet
               -E code arguments... : Evaluate  an expression as a short-fn with arguments
               -d : Set the debug flag in the REPL
               -r : Enter the REPL after running all scripts
               -R : Disables loading profile.janet when JANET_PROFILE is present
               -p : Keep on executing if there is a top-level error (persistent)
               -q : Hide logo (quiet)
               -k : Compile scripts but do not execute (flycheck)
               -m syspath : Set system path for loading global modules
               -c source output : Compile janet source code into an image
               -i : Load the script argument as an image file instead of source code
               -n : Disable ANSI color output in the REPL
               -l lib : Use a module before processing more arguments
               -w level : Set the lint warning level - default is "normal"
               -x level : Set the lint error level - default is "none"
               -- : Stop handling options
             ```)
           (os/exit 0)
           1)
     "v" (fn [&] (print janet/version "-" janet/build) (os/exit 0) 1)
     "s" (fn [&] (set raw-stdin true) (set should-repl true) 1)
     "r" (fn [&] (set should-repl true) 1)
     "p" (fn [&] (set exit-on-error false) 1)
     "q" (fn [&] (set quiet true) 1)
     "i" (fn [&] (set expect-image true) 1)
     "k" (fn [&] (set compile-only true) (set exit-on-error false) 1)
     "n" (fn [&] (set colorize false) 1)
     "m" (fn [i &] (setdyn *syspath* (in args (+ i 1))) 2)
     "c" (fn c-switch [i &]
           (def path (in args (+ i 1)))
           (def e (dofile path))
           (spit (in args (+ i 2)) (make-image e))
           (set no-file false)
           3)
     "-" (fn [&] (set handleopts false) 1)
     "l" (fn l-switch [i &]
           (import* (in args (+ i 1))
                    :prefix "" :exit exit-on-error)
           2)
     "e" (fn e-switch [i &]
           (set no-file false)
           (eval-string (in args (+ i 1)))
           2)
     "E" (fn E-switch [i &]
           (set no-file false)
           (def subargs (array/slice args (+ i 2)))
           (def src ~(short-fn ,(parse (in args (+ i 1))) E-expression))
           (def thunk (compile src))
           (if (function? thunk)
             ((thunk) ;subargs)
             (error (get thunk :error)))
           math/inf)
     "d" (fn [&] (set debug-flag true) 1)
     "w" (fn [i &] (set warn-level (get-lint-level i)) 2)
     "x" (fn [i &] (set error-level (get-lint-level i)) 2)
     "R" (fn [&] (setdyn *profilepath* nil) 1)})

  (defn- dohandler [n i &]
    (def h (in handlers n))
    (if h (h i) (do (print "unknown flag -" n) ((in handlers "h")))))

  # Process arguments
  (var i 0)
  (def lenargs (length args))
  (while (< i lenargs)
    (def arg (in args i))
    (if (and handleopts (= "-" (string/slice arg 0 1)))
      (+= i (dohandler (string/slice arg 1) i))
      (do
        (def subargs (array/slice args i))
        (set no-file false)
        (if expect-image
          (do
            (def env (load-image (slurp arg)))
            (put env *args* subargs)
            (put env *lint-error* error-level)
            (put env *lint-warn* warn-level)
            (when debug-flag
              (put env *debug* true)
              (put env *redef* true))
            (run-main env subargs arg))
          (do
            (def env (make-env))
            (put env *args* subargs)
            (put env *lint-error* error-level)
            (put env *lint-warn* warn-level)
            (when debug-flag
              (put env *debug* true)
              (put env *redef* true))
            (if compile-only
              (flycheck arg :exit exit-on-error :env env)
              (do
                (dofile arg :exit exit-on-error :env env)
                (run-main env subargs arg)))))
        (set i lenargs))))

  (if (or should-repl no-file)
    (if
      compile-only (flycheck stdin :source :stdin :exit exit-on-error)
      (do
        (if-not quiet
          (print "jref - Janet " janet/version "-" janet/build " "
                 (os/which) "/" (os/arch) "/" (os/compiler)
                 " - '(doc)' for help"))
        (flush)
        (when-let [prompt-fn (dyn *getprompt*)]
          (when (function? prompt-fn)
            (set getprompt prompt-fn)))
        (defn getstdin [prompt buf _]
          (file/write stdout prompt)
          (file/flush stdout)
          (file/read stdin :line buf))
        (def env (make-env))
        (when-let [profile.janet (dyn *profilepath*)]
          (def new-env (dofile profile.janet :exit true))
          (merge-module env new-env "" false))
        (when debug-flag
          (put env *debug* true)
          (put env *redef* true))
        (def getter (if raw-stdin getstdin getline))
        (defn getchunk [buf p]
          (getter (getprompt p) buf env))
        # XXX
        #(setdyn *pretty-format* (if colorize "%.20Q" "%.20q"))
        (put env *pretty-format*
             @{:value :pretty-format})
        (put env :pretty-format
             "# =>\n%q\n")
        (setdyn *err-color* (if colorize true))
        (setdyn *doc-color* (if colorize true))
        (setdyn *lint-error* error-level)
        (setdyn *lint-warn* error-level)
        # XXX
        #(repl getchunk nil env)
        # defining the following to customize output
        # customized the returned value of debugger-on-status in boot.janet
        (defn onsignal
          [fib x]
          (def fs (fiber/status fib))
          (if (= :dead fs)
            (when true
              (put env '_ @{:value x})
              (print "# =>")
              (print (data/fmt (string/format "%n" x)))
              (print)
              (flush))
            (do
              (debug/stacktrace fib x "")
              (eflush)
              (when (get env :debug)
                (debugger fib 1)))))
        (repl getchunk onsignal env)))))

