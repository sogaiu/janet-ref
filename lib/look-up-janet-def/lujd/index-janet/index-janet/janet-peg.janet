(import ./loc :as l)

(defn make-grammar
  [&opt opts]
  #
  (def opaque-node
    (or (get opts :opaque-node)
        (fn [the-type peg-form]
          ~(cmt (capture (sequence (line) (column) (position)
                                   ,peg-form
                                   (line) (column) (position)))
                ,|[the-type
                   (l/make-attrs ;(tuple/slice $& 0 3)
                                 ;(tuple/slice $& (- (- 3) 2) -2))
                   (last $&)]))))
  #
  (def delim-node
    (or (get opts :delim-node)
        (fn [the-type open close]
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
                (l/make-attrs ;(tuple/slice $& 0 3)
                              ;(tuple/slice $& (- (- 3) 2) -2))
                ;(tuple/slice $& 3 (- (- 3 ) 2))]))))
  #
  ~{:main (sequence (line) (column) (position)
                    (some :input)
                    (line) (column) (position))
    #
    :input (choice :ws
                   :cmt
                   :form)
    #
    :ws (choice :ws/horiz
                :ws/eol)
    #
    :ws/horiz ,(opaque-node :ws/horiz
                            '(some (set " \0\f\t\v")))
    #
    :ws/eol ,(opaque-node :ws/eol
                          '(choice "\r\n"
                                   "\r"
                                   "\n"))
    #
    :cmt :cmt/line
    #
    :cmt/line
    ,(opaque-node :cmt/line
                  '(sequence "#"
                             (any (if-not (set "\r\n") 1))))
    #
    :form (choice :str
                  :blob
                  :dl)
    #
    :str (choice :str/dq
                 :str/bt)
    #
    :str/dq
    ,(opaque-node :str/dq
                  '(sequence `"`
                             (any (choice :escape
                                          (if-not `"` 1)))
                             `"`))
    #
    :escape (sequence `\`
                      (choice (set `"'0?\abefnrtvz`)
                              (sequence "x" (2 :h))
                              (sequence "u" (4 :h))
                              (sequence "U" (6 :h))
                              (error (constant "bad escape"))))
    #
    :str/bt
    ,(opaque-node :str/bt
                  ~{:main (drop (sequence :open
                                          (any (if-not :close 1))
                                          :close))
                    :open (capture :delim :n)
                    :delim (some "`")
                    :close (cmt (sequence (not (look -1 "`"))
                                          (backref :n)
                                          (capture (backmatch :n)))
                                ,=)})
    #
    :blob
    ,(opaque-node
       :blob
       '(some (choice (range "09" "AZ" "az" "\x80\xFF")
                      (set "!$%&*+-./:<=>?^_")
                      # XXX: what to do about mutable collections...
                      "@"
                      # XXX: possibly separate...
                      (set "|~';,"))))
    #
    :dl (choice :dl/round
                :dl/square
                :dl/curly)
    #
    :dl/round ,(delim-node :dl/round "(" ")")
    #
    :dl/square ,(delim-node :dl/square "[" "]")
    #
    :dl/curly ,(delim-node :dl/curly "{" "}")})

(comment

  (def grammar (make-grammar))

  (get (peg/match grammar `2`) 3)
  # =>
  '(:blob @{:bc 1 :bl 1 :bp 0
            :ec 2 :el 1 :ep 1}
          "2")

  (get (peg/match grammar `(+ 1 1)`) 3)
  # =>
  '(:dl/round @{:bc 1 :bl 1 :bp 0 :ec 8 :el 1 :ep 7}
              (:blob @{:bc 2 :bl 1 :bp 1 :ec 3 :el 1 :ep 2} "+")
              (:ws/horiz @{:bc 3 :bl 1 :bp 2 :ec 4 :el 1 :ep 3} " ")
              (:blob @{:bc 4 :bl 1 :bp 3 :ec 5 :el 1 :ep 4} "1")
              (:ws/horiz @{:bc 5 :bl 1 :bp 4 :ec 6 :el 1 :ep 5} " ")
              (:blob @{:bc 6 :bl 1 :bp 5 :ec 7 :el 1 :ep 6} "1"))

  (-> (peg/match grammar `@[:a :b :c]`)
      (array/slice 3 (dec (- 3))))
  # =>
  '@[(:blob @{:bc 1 :bl 1 :bp 0 :ec 2 :el 1 :ep 1} "@")
     (:dl/square @{:bc 2 :bl 1 :bp 1 :ec 12 :el 1 :ep 11}
                 (:blob @{:bc 3 :bl 1 :bp 2 :ec 5 :el 1 :ep 4} ":a")
                 (:ws/horiz @{:bc 5 :bl 1 :bp 4 :ec 6 :el 1 :ep 5} " ")
                 (:blob @{:bc 6 :bl 1 :bp 5 :ec 8 :el 1 :ep 7} ":b")
                 (:ws/horiz @{:bc 8 :bl 1 :bp 7 :ec 9 :el 1 :ep 8} " ")
                 (:blob @{:bc 9 :bl 1 :bp 8 :ec 11 :el 1 :ep 10} ":c"))]

  (get (peg/match grammar
                  ``
                  (defn fun
                    [x]
                    (+ x 1))
                  ``)
       3)
  # =>
  '(:dl/round
     @{:bc 1 :bl 1 :bp 0 :ec 11 :el 3 :ep 26}
     (:blob @{:bc 2 :bl 1 :bp 1 :ec 6 :el 1 :ep 5} "defn")
     (:ws/horiz @{:bc 6 :bl 1 :bp 5 :ec 7 :el 1 :ep 6} " ")
     (:blob @{:bc 7 :bl 1 :bp 6 :ec 10 :el 1 :ep 9} "fun")
     (:ws/eol @{:bc 10 :bl 1 :bp 9 :ec 1 :el 2 :ep 10} "\n")
     (:ws/horiz @{:bc 1 :bl 2 :bp 10 :ec 3 :el 2 :ep 12} "  ")
     (:dl/square @{:bc 3 :bl 2 :bp 12 :ec 6 :el 2 :ep 15}
                 (:blob @{:bc 4 :bl 2 :bp 13 :ec 5 :el 2 :ep 14} "x"))
     (:ws/eol @{:bc 6 :bl 2 :bp 15 :ec 1 :el 3 :ep 16} "\n")
     (:ws/horiz @{:bc 1 :bl 3 :bp 16 :ec 3 :el 3 :ep 18} "  ")
     (:dl/round @{:bc 3 :bl 3 :bp 18 :ec 10 :el 3 :ep 25}
                (:blob @{:bc 4 :bl 3 :bp 19 :ec 5 :el 3 :ep 20} "+")
                (:ws/horiz @{:bc 5 :bl 3 :bp 20 :ec 6 :el 3 :ep 21} " ")
                (:blob @{:bc 6 :bl 3 :bp 21 :ec 7 :el 3 :ep 22} "x")
                (:ws/horiz @{:bc 7 :bl 3 :bp 22 :ec 8 :el 3 :ep 23} " ")
                (:blob @{:bc 8 :bl 3 :bp 23 :ec 9 :el 3 :ep 24} "1")))

  (get (peg/match grammar
                  ``
                  (print # nice comment
                    "hello")
                  ``)
       3)
  # =>
  '(:dl/round
     @{:bc 1 :bl 1 :bp 0 :ec 11 :el 2 :ep 32}
     (:blob @{:bc 2 :bl 1 :bp 1 :ec 7 :el 1 :ep 6} "print")
     (:ws/horiz @{:bc 7 :bl 1 :bp 6 :ec 8 :el 1 :ep 7} " ")
     (:cmt/line @{:bc 8 :bl 1 :bp 7 :ec 22 :el 1 :ep 21} "# nice comment")
     (:ws/eol @{:bc 22 :bl 1 :bp 21 :ec 1 :el 2 :ep 22} "\n")
     (:ws/horiz @{:bc 1 :bl 2 :bp 22 :ec 3 :el 2 :ep 24} "  ")
     (:str/dq @{:bc 3 :bl 2 :bp 24 :ec 10 :el 2 :ep 31} "\"hello\""))

  )

