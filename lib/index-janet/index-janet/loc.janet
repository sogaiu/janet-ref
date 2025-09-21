# bl - begin line
# bc - begin column
# bp - begin position
# el - end line
# ec - end column
# ep - end position
(defn make-attrs
  [& args]
  (zipcoll [:bl :bc :bp :el :ec :ep]
           args))

(comment

  (make-attrs 1 1 0
              10 20 50)
  # =>
  @{:bc 1 :bl 1 :bp 0 :ec 20 :el 10 :ep 50}

  )

(comment

  (defn opaque-node
    [the-type peg-form]
    ~(cmt (capture (sequence (line) (column) (position)
                             ,peg-form
                             (line) (column) (position)))
          ,|[the-type
             (make-attrs ;(tuple/slice $& 0 3)
                         ;(tuple/slice $& (- (- 3) 2) -2))
             (last $&)]))

  (defn delim-node
    [the-type open close]
    ~(cmt
       (capture
         (sequence
           (line) (column) (position)
           ,open
           (any :input)
           (choice ,close
                   (error
                     (replace (sequence (line) (column) (position))
                              ,|(string/format
                                  (string "line: %d column: %d pos: %d "
                                          "missing %s for %s")
                                  $0 $1 $2 close the-type))))
           (line) (column) (position)))
       ,|[the-type
          (make-attrs ;(tuple/slice $& 0 3)
                      ;(tuple/slice $& (- (- 3) 2) -2))
          ;(tuple/slice $& 3 (- (- 3 ) 2))]))

  (def t-grammar
    ~{:main (some :input)
      :input (choice :ws :str :dl)
      :ws ,(opaque-node :ws '(set " \n"))
      :str ,(opaque-node :str
                         '(sequence `"`
                                    (any (if-not `"` 1))
                                    `"`))
      :dl ,(delim-node :dl `(` `)`)})

  (peg/match t-grammar `"hi there"`)
  # =>
  '@[(:str @{:bc 1 :bl 1 :bp 0 :ec 11 :el 1 :ep 10} "\"hi there\"")]

  (peg/match t-grammar `("alice" "bob")`)
  # =>
  '@[(:dl @{:bc 1 :bl 1 :bp 0 :ec 16 :el 1 :ep 15}
          (:str @{:bc 2 :bl 1 :bp 1 :ec 9 :el 1 :ep 8} "\"alice\"")
          (:ws @{:bc 9 :bl 1 :bp 8 :ec 10 :el 1 :ep 9} " ")
          (:str @{:bc 10 :bl 1 :bp 9 :ec 15 :el 1 :ep 14} "\"bob\""))]

  )

