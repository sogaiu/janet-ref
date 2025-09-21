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
                            '(some (set " \f\t\v")))
    #
    :ws/eol ,(opaque-node :ws/eol
                          '(choice "\r\n"
                                   "\r"
                                   "\n"))
    #
    :cmt (choice :cmt/line
                 :cmt/m-line)
    #
    :cmt/line
    ,(opaque-node :cmt/line
                  '(sequence "//"
                             (any (if-not (set "\r\n") 1))))
    # c multi-line comments are not allowed to nest apparently, so
    # may be the following works
    :cmt/m-line
    ,(opaque-node :cmt/m-line
                  '(sequence "/*"
                             (any (if-not `*/` 1))
                             "*/"))
    #
    :form (choice :str
                  :blob
                  :dl)
    #
    :str (choice :str/dq
                 :str/sq)
    #
    :str/dq
    ,(opaque-node :str/dq
                  '(sequence `"`
                             (any (choice :escape
                                          (if-not `"` 1)))
                             `"`))
    #
    :escape (sequence `\`
                      (choice (set `abefnrtv\'"?`)
                              (between 1 3 (range "07"))
                              (sequence "x" :d+)
                              (sequence "u" (4 :h))
                              (sequence "U" (8 :h))))
    #
    :str/sq
    ,(opaque-node :str/sq
                  '(sequence `'`
                             (some (choice :escape
                                           (if-not `'` 1)))
                             `'`))
    #
    :blob
    ,(opaque-node
       :blob
       '(some (choice :a
                      :d
                      # XXX: $, @, and ` not allowed in C?
                      (set `!#%&*+,-./:;<=>?\^_|~`))))
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

  (get (peg/match grammar `{ 1 + 1; }`) 3)
  # =>
  '(:dl/curly @{:bc 1 :bl 1 :bp 0 :ec 11 :el 1 :ep 10}
              (:ws/horiz @{:bc 2 :bl 1 :bp 1 :ec 3 :el 1 :ep 2} " ")
              (:blob @{:bc 3 :bl 1 :bp 2 :ec 4 :el 1 :ep 3} "1")
              (:ws/horiz @{:bc 4 :bl 1 :bp 3 :ec 5 :el 1 :ep 4} " ")
              (:blob @{:bc 5 :bl 1 :bp 4 :ec 6 :el 1 :ep 5} "+")
              (:ws/horiz @{:bc 6 :bl 1 :bp 5 :ec 7 :el 1 :ep 6} " ")
              (:blob @{:bc 7 :bl 1 :bp 6 :ec 9 :el 1 :ep 8} "1;")
              (:ws/horiz @{:bc 9 :bl 1 :bp 8 :ec 10 :el 1 :ep 9} " "))

  (array/slice (peg/match grammar
                          ``
                          int main(int argc, char **argv) {
                            return 0;
                          }
                          ``)
               3 (dec (- 3)))
  # =>
  '@[(:blob @{:bc 1 :bl 1 :bp 0 :ec 4 :el 1 :ep 3} "int")
     (:ws/horiz @{:bc 4 :bl 1 :bp 3 :ec 5 :el 1 :ep 4} " ")
     (:blob @{:bc 5 :bl 1 :bp 4 :ec 9 :el 1 :ep 8} "main")
     (:dl/round @{:bc 9 :bl 1 :bp 8 :ec 32 :el 1 :ep 31}
                (:blob @{:bc 10 :bl 1 :bp 9 :ec 13 :el 1 :ep 12} "int")
                (:ws/horiz @{:bc 13 :bl 1 :bp 12 :ec 14 :el 1 :ep 13} " ")
                (:blob @{:bc 14 :bl 1 :bp 13 :ec 19 :el 1 :ep 18} "argc,")
                (:ws/horiz @{:bc 19 :bl 1 :bp 18 :ec 20 :el 1 :ep 19} " ")
                (:blob @{:bc 20 :bl 1 :bp 19 :ec 24 :el 1 :ep 23} "char")
                (:ws/horiz @{:bc 24 :bl 1 :bp 23 :ec 25 :el 1 :ep 24} " ")
                (:blob @{:bc 25 :bl 1 :bp 24 :ec 31 :el 1 :ep 30} "**argv"))
     (:ws/horiz @{:bc 32 :bl 1 :bp 31 :ec 33 :el 1 :ep 32} " ")
     (:dl/curly @{:bc 33 :bl 1 :bp 32 :ec 2 :el 3 :ep 47}
                (:ws/eol @{:bc 34 :bl 1 :bp 33 :ec 1 :el 2 :ep 34} "\n")
                (:ws/horiz @{:bc 1 :bl 2 :bp 34 :ec 3 :el 2 :ep 36} "  ")
                (:blob @{:bc 3 :bl 2 :bp 36 :ec 9 :el 2 :ep 42} "return")
                (:ws/horiz @{:bc 9 :bl 2 :bp 42 :ec 10 :el 2 :ep 43} " ")
                (:blob @{:bc 10 :bl 2 :bp 43 :ec 12 :el 2 :ep 45} "0;")
                (:ws/eol @{:bc 12 :bl 2 :bp 45 :ec 1 :el 3 :ep 46} "\n"))]

  (array/slice (peg/match grammar
                          ``
                          // a comment
                          { int a = 3; }
                          ``)
               3 (dec (- 3)))
  # =>
  '@[(:cmt/line @{:bc 1 :bl 1 :bp 0 :ec 13 :el 1 :ep 12} "// a comment")
     (:ws/eol @{:bc 13 :bl 1 :bp 12 :ec 1 :el 2 :ep 13} "\n")
     (:dl/curly @{:bc 1 :bl 2 :bp 13 :ec 15 :el 2 :ep 27}
                (:ws/horiz @{:bc 2 :bl 2 :bp 14 :ec 3 :el 2 :ep 15} " ")
                (:blob @{:bc 3 :bl 2 :bp 15 :ec 6 :el 2 :ep 18} "int")
                (:ws/horiz @{:bc 6 :bl 2 :bp 18 :ec 7 :el 2 :ep 19} " ")
                (:blob @{:bc 7 :bl 2 :bp 19 :ec 8 :el 2 :ep 20} "a")
                (:ws/horiz @{:bc 8 :bl 2 :bp 20 :ec 9 :el 2 :ep 21} " ")
                (:blob @{:bc 9 :bl 2 :bp 21 :ec 10 :el 2 :ep 22} "=")
                (:ws/horiz @{:bc 10 :bl 2 :bp 22 :ec 11 :el 2 :ep 23} " ")
                (:blob @{:bc 11 :bl 2 :bp 23 :ec 13 :el 2 :ep 25} "3;")
                (:ws/horiz @{:bc 13 :bl 2 :bp 25 :ec 14 :el 2 :ep 26} " "))]

  )

