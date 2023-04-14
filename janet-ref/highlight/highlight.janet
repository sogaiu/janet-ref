(import ./color :prefix "")
(import ../parse/location :as loc)
(import ./mono :prefix "")
(import ./rgb :prefix "")
(import ./theme :prefix "")

(defn maybe-color
  [an-ast a-type]
  ((dyn :jref-hl-str mono-str)
    (in an-ast 2)
    ((dyn :jref-theme mono-theme) a-type)))

(defn maybe-color-symbol
  [an-ast]
  ((dyn :jref-hl-str mono-str)
    (in an-ast 2)
    ((dyn :jref-theme mono-theme) :symbol)))

(defn gen*
  [an-ast buf]
  (case (first an-ast)
    :code
    (each elt (drop 2 an-ast)
      (gen* elt buf))
    #
    :buffer
    (buffer/push-string buf (maybe-color an-ast :buffer))
    :comment
    (buffer/push-string buf (maybe-color an-ast :comment))
    :constant
    (buffer/push-string buf (maybe-color an-ast :constant))
    :keyword
    (buffer/push-string buf (maybe-color an-ast :keyword))
    :long-buffer
    (buffer/push-string buf (maybe-color an-ast :long-buffer))
    :long-string
    (buffer/push-string buf (maybe-color an-ast :long-string))
    :number
    (buffer/push-string buf (maybe-color an-ast :number))
    :string
    (buffer/push-string buf (maybe-color an-ast :string))
    :symbol
    (buffer/push-string buf (maybe-color-symbol an-ast))
    :unreadable
    (buffer/push-string buf (maybe-color an-ast :unreadable))
    :whitespace
    (buffer/push-string buf (in an-ast 2))
    #
    :array
    (do
      (buffer/push-string buf "@(")
      (each elt (drop 2 an-ast)
        (gen* elt buf))
      (buffer/push-string buf ")"))
    :bracket-array
    (do
      (buffer/push-string buf "@[")
      (each elt (drop 2 an-ast)
        (gen* elt buf))
      (buffer/push-string buf "]"))
    :bracket-tuple
    (do
      (buffer/push-string buf "[")
      (each elt (drop 2 an-ast)
        (gen* elt buf))
      (buffer/push-string buf "]"))
    :tuple
    (do
      (buffer/push-string buf "(")
      (each elt (drop 2 an-ast)
        (gen* elt buf))
      (buffer/push-string buf ")"))
    :struct
    (do
      (buffer/push-string buf "{")
      (each elt (drop 2 an-ast)
        (gen* elt buf))
      (buffer/push-string buf "}"))
    :table
    (do
      (buffer/push-string buf "@{")
      (each elt (drop 2 an-ast)
        (gen* elt buf))
      (buffer/push-string buf "}"))
    #
    :fn
    (do
      (buffer/push-string buf "|")
      (each elt (drop 2 an-ast)
        (gen* elt buf)))
    :quasiquote
    (do
      (buffer/push-string buf "~")
      (each elt (drop 2 an-ast)
        (gen* elt buf)))
    :quote
    (do
      (buffer/push-string buf "'")
      (each elt (drop 2 an-ast)
        (gen* elt buf)))
    :splice
    (do
      (buffer/push-string buf ";")
      (each elt (drop 2 an-ast)
        (gen* elt buf)))
    :unquote
    (do
      (buffer/push-string buf ",")
      (each elt (drop 2 an-ast)
        (gen* elt buf)))
    ))

(defn gen
  [an-ast]
  (let [buf @""]
    (gen* an-ast buf)
    (string buf)))

(comment

  (gen
    [:code])
  # =>
  ""

  (gen
    '(:whitespace @{:bc 1 :bl 1
                    :ec 2 :el 1} " "))
  # =>
  " "

  (gen
    '(:buffer @{:bc 1 :bl 1
                :ec 12 :el 1} "@\"a buffer\""))
  # =>
  `@"a buffer"`

  (gen
    '@[:code @{:bc 1 :bl 1
               :ec 8 :el 1}
       (:tuple @{:bc 1 :bl 1
                 :ec 8 :el 1}
               (:symbol @{:bc 2 :bl 1
                          :ec 3 :el 1} "+")
               (:whitespace @{:bc 3 :bl 1
                              :ec 4 :el 1} " ")
               (:number @{:bc 4 :bl 1
                          :ec 5 :el 1} "1")
               (:whitespace @{:bc 5 :bl 1
                              :ec 6 :el 1} " ")
               (:number @{:bc 6 :bl 1
                          :ec 7 :el 1} "1"))])
  # =>
  "(+ 1 1)"

  (gen
    '@[:code @{}
       (:unreadable @{:bc 1 :bl 1 :ec 22 :el 1}
                    "<core/peg 0xdeedabba>")])
  # =>
  "<core/peg 0xdeedabba>"

  )

(defn colorize
  [src]
  (gen (loc/par src)))

(comment

  (def src "{:x  :y \n :z  [:a  :b    :c]}")

  (colorize src)

  (def src-2 "(peg/match ~(any \"a\") \"abc\")")

  (colorize src-2)

  )

