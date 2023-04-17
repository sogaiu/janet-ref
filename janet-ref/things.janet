(import ./random :as rnd)

# wanted an escaping scheme that satisfied the following constraints:
#
# * works with janet symbols
# * works with windows and *nix
# * can be easily adapted for use in urls
# * relatively readable / typable
# * relatively brief
#
# result was:
#
# * use square brackets to surround abbreviated character entity ref names
# * thus:
#   * / -> [sol]
#   * < -> [lt]
#   * > -> [gt]
#   * * -> [ast]
#   * % -> [per]
#   * : -> [col]
#   * ? -> [que]
(def sym-char-escapes
  {"/" "sol"
   "<" "lt"
   ">" "gt"
   "*" "ast"
   "%" "per"
   ":" "col"
   "?" "que"})

(defn escape-sym-name
  [sym-name]
  (def esc-grammar
    (peg/compile
      ~(accumulate
         (some
           (choice (replace (capture (set "/<>*%:?"))
                            ,(fn [char-str]
                               (string "["
                                       (get sym-char-escapes char-str)
                                       "]")))
                   (capture 1))))))
  (first (peg/match esc-grammar sym-name)))

(comment

  (escape-sym-name "string/replace")
  # =>
  "string[sol]replace"

  (escape-sym-name "<")
  # =>
  "[lt]"

  (escape-sym-name "->")
  # =>
  "-[gt]"

  (escape-sym-name "import*")
  # =>
  "import[ast]"

  (escape-sym-name "%=")
  # =>
  "[per]="

  (escape-sym-name "uncommon:symbol")
  # =>
  "uncommon[col]symbol"

  (escape-sym-name "nan?")
  # =>
  "nan[que]"

  )

(def sym-char-unescapes
  (invert sym-char-escapes))

(defn unescape-file-name
  [file-name]
  (def unesc-grammar
    (peg/compile
      ~(accumulate
         (some
           (choice (replace (sequence "["
                                      (capture (to "]"))
                                      "]")
                            ,sym-char-unescapes)
                   (capture 1))))))
  (first (peg/match unesc-grammar file-name)))

(comment

  (unescape-file-name "string[sol]replace")
  # =>
  "string/replace"

  (unescape-file-name "[lt]")
  # =>
  "<"

  (unescape-file-name "-[gt]")
  # =>
  "->"

  (unescape-file-name "import[ast]")
  # =>
  "import*"

  (unescape-file-name "[per]=")
  # =>
  "%="

  (unescape-file-name "uncommon[col]symbol")
  # =>
  "uncommon:symbol"

  (unescape-file-name "nan[que]")
  # =>
  "nan?"

  )

(def aliases-table
  # XXX: what's missing?
  {"|" "fn"
   "~" "quasiquote"
   "'" "quote"
   ";" "splice"
   "," "unquote"})

(defn all-things
  [file-names]
  (def things
    (->> file-names
         # drop .janet extension
         (map |(string/slice $ 0
                             (last (string/find-all "." $))))
         # only keep things that have names
         (filter |(not (string/has-prefix? "0." $)))
         (keep unescape-file-name)))
  # add aliases
  (each alias (keys aliases-table)
    (let [thing (get aliases-table alias)]
      (unless (string/has-prefix? "0." thing)
        (when (index-of thing things)
          (array/push things alias)))))
  #
  things)

(comment

  (all-things ["[lt].janet"
               "mapcat.janet"
               "nan[que].janet"
               "string[sol]format.janet"])
  # =>
  @["<" "mapcat" "nan?" "string/format"]

  (all-things ["0.all-the-things.janet"
               "-[gt].janet"
               "array[sol]push.janet"
               "map.janet"
               "nan[que].janet"])
  # =>
  @["->" "array/push" "map" "nan?"]

  )

(defn choose-random-thing
  [file-names]
  (def all-idx
    (index-of "0.all-the-things.janet" file-names))
  (def choice-names
    (array/slice file-names))
  (when all-idx
    (array/remove choice-names all-idx))
  (def file-name
    (rnd/choose choice-names))
  # return name without extension
  (->> (string/slice file-name 0
                     (last (string/find-all "." file-name)))
       unescape-file-name))

(comment

  (let [file-names
        @["[lt].janet"
          "nan[que].janet"
          "string[sol]format.janet"]
        thing-names
        (map |(let [name-only
                    (string/slice $
                                  0 (last (string/find-all "." $)))]
                (unescape-file-name name-only))
             file-names)
        thing
        (choose-random-thing file-names)]
    [(truthy? (index-of thing thing-names))
     (string/find "[" thing)])
  # =>
  [true nil]

  )

