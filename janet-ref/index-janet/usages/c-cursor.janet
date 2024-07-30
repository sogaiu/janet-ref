(import ../index-janet/c-cursor :as cc)

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (cc/make-infra))

  (par
    ``
    int main(int argc, char** argv) {
      return 0;
    }
    ``)
  # =>
  '@[:code @{:bc 1 :bl 1 :bp 0
             :ec 2 :el 3 :ep 47 :id 0}
     (:blob @{:bc 1 :bl 1 :bp 0
              :ec 4 :el 1 :ep 3 :id 1 :idx 0 :pid 0} "int")
     (:ws/horiz @{:bc 4 :bl 1 :bp 3
                  :ec 5 :el 1 :ep 4 :id 2 :idx 1 :pid 0} " ")
     (:blob @{:bc 5 :bl 1 :bp 4
              :ec 9 :el 1 :ep 8 :id 3 :idx 2 :pid 0} "main")
     (:dl/round @{:bc 9 :bl 1 :bp 8
                  :ec 32 :el 1 :ep 31 :id 11 :idx 3 :pid 0}
                (:blob @{:bc 10 :bl 1 :bp 9
                         :ec 13 :el 1 :ep 12 :id 4 :idx 0 :pid 11} "int")
                (:ws/horiz @{:bc 13 :bl 1 :bp 12
                             :ec 14 :el 1 :ep 13 :id 5 :idx 1 :pid 11} " ")
                (:blob @{:bc 14 :bl 1 :bp 13
                         :ec 19 :el 1 :ep 18 :id 6 :idx 2 :pid 11} "argc,")
                (:ws/horiz @{:bc 19 :bl 1 :bp 18
                             :ec 20 :el 1 :ep 19 :id 7 :idx 3 :pid 11} " ")
                (:blob @{:bc 20 :bl 1 :bp 19
                         :ec 26 :el 1 :ep 25 :id 8 :idx 4 :pid 11} "char**")
                (:ws/horiz @{:bc 26 :bl 1 :bp 25
                             :ec 27 :el 1 :ep 26 :id 9 :idx 5 :pid 11} " ")
                (:blob @{:bc 27 :bl 1 :bp 26
                         :ec 31 :el 1 :ep 30 :id 10 :idx 6 :pid 11} "argv"))
     (:ws/horiz @{:bc 32 :bl 1 :bp 31
                  :ec 33 :el 1 :ep 32 :id 12 :idx 4 :pid 0} " ")
     (:dl/curly @{:bc 33 :bl 1 :bp 32
                  :ec 2 :el 3 :ep 47 :id 19 :idx 5 :pid 0}
                (:ws/eol @{:bc 34 :bl 1 :bp 33
                           :ec 1 :el 2 :ep 34 :id 13 :idx 0 :pid 19} "\n")
                (:ws/horiz @{:bc 1 :bl 2 :bp 34
                             :ec 3 :el 2 :ep 36 :id 14 :idx 1 :pid 19} "  ")
                (:blob @{:bc 3 :bl 2 :bp 36
                         :ec 9 :el 2 :ep 42 :id 15 :idx 2 :pid 19} "return")
                (:ws/horiz @{:bc 9 :bl 2 :bp 42
                             :ec 10 :el 2 :ep 43 :id 16 :idx 3 :pid 19} " ")
                (:blob @{:bc 10 :bl 2 :bp 43
                         :ec 12 :el 2 :ep 45 :id 17 :idx 4 :pid 19} "0;")
                (:ws/eol @{:bc 12 :bl 2 :bp 45
                           :ec 1 :el 3 :ep 46 :id 18 :idx 5 :pid 19} "\n"))]

  id->node
  # =>
  '@{0 @[:code @{:bc 1 :bl 1 :bp 0
                 :ec 2 :el 3 :ep 47
                 :id 0}
         (:blob @{:bc 1 :bl 1 :bp 0
                  :ec 4 :el 1 :ep 3
                  :id 1 :idx 0 :pid 0} "int")
         (:ws/horiz @{:bc 4 :bl 1 :bp 3
                      :ec 5 :el 1 :ep 4
                      :id 2 :idx 1 :pid 0} " ")
         (:blob @{:bc 5 :bl 1 :bp 4
                  :ec 9 :el 1 :ep 8
                  :id 3 :idx 2 :pid 0} "main")
         (:dl/round @{:bc 9 :bl 1 :bp 8
                      :ec 32 :el 1 :ep 31
                      :id 11 :idx 3 :pid 0}
                    (:blob @{:bc 10 :bl 1 :bp 9
                             :ec 13 :el 1 :ep 12
                             :id 4 :idx 0 :pid 11} "int")
                    (:ws/horiz @{:bc 13 :bl 1 :bp 12
                                 :ec 14 :el 1 :ep 13
                                 :id 5 :idx 1 :pid 11} " ")
                    (:blob @{:bc 14 :bl 1 :bp 13
                             :ec 19 :el 1 :ep 18
                             :id 6 :idx 2 :pid 11} "argc,")
                    (:ws/horiz @{:bc 19 :bl 1 :bp 18
                                 :ec 20 :el 1 :ep 19
                                 :id 7 :idx 3 :pid 11} " ")
                    (:blob @{:bc 20 :bl 1 :bp 19
                             :ec 26 :el 1 :ep 25
                             :id 8 :idx 4 :pid 11} "char**")
                    (:ws/horiz @{:bc 26 :bl 1 :bp 25
                                 :ec 27 :el 1 :ep 26
                                 :id 9 :idx 5 :pid 11} " ")
                    (:blob @{:bc 27 :bl 1 :bp 26
                             :ec 31 :el 1 :ep 30
                             :id 10 :idx 6 :pid 11} "argv"))
         (:ws/horiz @{:bc 32 :bl 1 :bp 31
                      :ec 33 :el 1 :ep 32
                      :id 12 :idx 4 :pid 0} " ")
         (:dl/curly @{:bc 33 :bl 1 :bp 32
                      :ec 2 :el 3 :ep 47
                      :id 19 :idx 5 :pid 0}
                    (:ws/eol @{:bc 34 :bl 1 :bp 33
                               :ec 1 :el 2 :ep 34
                               :id 13 :idx 0 :pid 19} "\n")
                    (:ws/horiz @{:bc 1 :bl 2 :bp 34
                                 :ec 3 :el 2 :ep 36
                                 :id 14 :idx 1 :pid 19} "  ")
                    (:blob @{:bc 3 :bl 2 :bp 36
                             :ec 9 :el 2 :ep 42
                             :id 15 :idx 2 :pid 19} "return")
                    (:ws/horiz @{:bc 9 :bl 2 :bp 42
                                 :ec 10 :el 2 :ep 43
                                 :id 16 :idx 3 :pid 19} " ")
                    (:blob @{:bc 10 :bl 2 :bp 43
                             :ec 12 :el 2 :ep 45
                             :id 17 :idx 4 :pid 19} "0;")
                    (:ws/eol @{:bc 12 :bl 2 :bp 45
                               :ec 1 :el 3 :ep 46
                               :id 18 :idx 5 :pid 19} "\n"))] 1
     (:blob @{:bc 1 :bl 1 :bp 0
              :ec 4 :el 1 :ep 3
              :id 1 :idx 0 :pid 0} "int") 2
     (:ws/horiz @{:bc 4 :bl 1 :bp 3
                  :ec 5 :el 1 :ep 4
                  :id 2 :idx 1 :pid 0} " ") 3
     (:blob @{:bc 5 :bl 1 :bp 4
              :ec 9 :el 1 :ep 8
              :id 3 :idx 2 :pid 0} "main") 4
     (:blob @{:bc 10 :bl 1 :bp 9
              :ec 13 :el 1 :ep 12
              :id 4 :idx 0 :pid 11} "int") 5
     (:ws/horiz @{:bc 13 :bl 1 :bp 12
                  :ec 14 :el 1 :ep 13
                  :id 5 :idx 1 :pid 11} " ") 6
     (:blob @{:bc 14 :bl 1 :bp 13
              :ec 19 :el 1 :ep 18
              :id 6 :idx 2 :pid 11} "argc,") 7
     (:ws/horiz @{:bc 19 :bl 1 :bp 18
                  :ec 20 :el 1 :ep 19
                  :id 7 :idx 3 :pid 11} " ") 8
     (:blob @{:bc 20 :bl 1 :bp 19
              :ec 26 :el 1 :ep 25
              :id 8 :idx 4 :pid 11} "char**") 9
     (:ws/horiz @{:bc 26 :bl 1 :bp 25
                  :ec 27 :el 1 :ep 26
                  :id 9 :idx 5 :pid 11} " ") 10
     (:blob @{:bc 27 :bl 1 :bp 26
              :ec 31 :el 1 :ep 30
              :id 10 :idx 6 :pid 11} "argv") 11
     (:dl/round @{:bc 9 :bl 1 :bp 8
                  :ec 32 :el 1 :ep 31
                  :id 11 :idx 3 :pid 0}
                (:blob @{:bc 10 :bl 1 :bp 9
                         :ec 13 :el 1 :ep 12
                         :id 4 :idx 0 :pid 11} "int")
                (:ws/horiz @{:bc 13 :bl 1 :bp 12
                             :ec 14 :el 1 :ep 13
                             :id 5 :idx 1 :pid 11} " ")
                (:blob @{:bc 14 :bl 1 :bp 13
                         :ec 19 :el 1 :ep 18
                         :id 6 :idx 2 :pid 11} "argc,")
                (:ws/horiz @{:bc 19 :bl 1 :bp 18
                             :ec 20 :el 1 :ep 19
                             :id 7 :idx 3 :pid 11} " ")
                (:blob @{:bc 20 :bl 1 :bp 19
                         :ec 26 :el 1 :ep 25
                         :id 8 :idx 4 :pid 11} "char**")
                (:ws/horiz @{:bc 26 :bl 1 :bp 25
                             :ec 27 :el 1 :ep 26
                             :id 9 :idx 5 :pid 11} " ")
                (:blob @{:bc 27 :bl 1 :bp 26
                         :ec 31 :el 1 :ep 30
                         :id 10 :idx 6 :pid 11} "argv")) 12
     (:ws/horiz @{:bc 32 :bl 1 :bp 31
                  :ec 33 :el 1 :ep 32
                  :id 12 :idx 4 :pid 0} " ") 13
     (:ws/eol @{:bc 34 :bl 1 :bp 33
                :ec 1 :el 2 :ep 34
                :id 13 :idx 0 :pid 19} "\n") 14
     (:ws/horiz @{:bc 1 :bl 2 :bp 34
                  :ec 3 :el 2 :ep 36
                  :id 14 :idx 1 :pid 19} "  ") 15
     (:blob @{:bc 3 :bl 2 :bp 36
              :ec 9 :el 2 :ep 42
              :id 15 :idx 2 :pid 19} "return") 16
     (:ws/horiz @{:bc 9 :bl 2 :bp 42
                  :ec 10 :el 2 :ep 43
                  :id 16 :idx 3 :pid 19} " ") 17
     (:blob @{:bc 10 :bl 2 :bp 43
              :ec 12 :el 2 :ep 45
              :id 17 :idx 4 :pid 19} "0;") 18
     (:ws/eol @{:bc 12 :bl 2 :bp 45
                :ec 1 :el 3 :ep 46
                :id 18 :idx 5 :pid 19} "\n") 19
     (:dl/curly @{:bc 33 :bl 1 :bp 32
                  :ec 2 :el 3 :ep 47
                  :id 19 :idx 5 :pid 0}
                (:ws/eol @{:bc 34 :bl 1 :bp 33
                           :ec 1 :el 2 :ep 34
                           :id 13 :idx 0 :pid 19} "\n")
                (:ws/horiz @{:bc 1 :bl 2 :bp 34
                             :ec 3 :el 2 :ep 36
                             :id 14 :idx 1 :pid 19} "  ")
                (:blob @{:bc 3 :bl 2 :bp 36
                         :ec 9 :el 2 :ep 42
                         :id 15 :idx 2 :pid 19} "return")
                (:ws/horiz @{:bc 9 :bl 2 :bp 42
                             :ec 10 :el 2 :ep 43
                             :id 16 :idx 3 :pid 19} " ")
                (:blob @{:bc 10 :bl 2 :bp 43
                         :ec 12 :el 2 :ep 45
                         :id 17 :idx 4 :pid 19} "0;")
                (:ws/eol @{:bc 12 :bl 2 :bp 45
                           :ec 1 :el 3 :ep 46
                           :id 18 :idx 5 :pid 19} "\n"))}

  )

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (cc/make-infra))

  (par "int a = 1 + 1;")
  # =>
  '@[:code @{:bc 1 :bl 1 :bp 0
             :ec 15 :el 1 :ep 14 :id 0}
     (:blob @{:bc 1 :bl 1 :bp 0
              :ec 4 :el 1 :ep 3 :id 1 :idx 0 :pid 0} "int")
     (:ws/horiz @{:bc 4 :bl 1 :bp 3
                  :ec 5 :el 1 :ep 4 :id 2 :idx 1 :pid 0} " ")
     (:blob @{:bc 5 :bl 1 :bp 4
              :ec 6 :el 1 :ep 5 :id 3 :idx 2 :pid 0} "a")
     (:ws/horiz @{:bc 6 :bl 1 :bp 5
                  :ec 7 :el 1 :ep 6 :id 4 :idx 3 :pid 0} " ")
     (:blob @{:bc 7 :bl 1 :bp 6
              :ec 8 :el 1 :ep 7 :id 5 :idx 4 :pid 0} "=")
     (:ws/horiz @{:bc 8 :bl 1 :bp 7
                  :ec 9 :el 1 :ep 8 :id 6 :idx 5 :pid 0} " ")
     (:blob @{:bc 9 :bl 1 :bp 8
              :ec 10 :el 1 :ep 9 :id 7 :idx 6 :pid 0} "1")
     (:ws/horiz @{:bc 10 :bl 1 :bp 9
                  :ec 11 :el 1 :ep 10 :id 8 :idx 7 :pid 0} " ")
     (:blob @{:bc 11 :bl 1 :bp 10
              :ec 12 :el 1 :ep 11 :id 9 :idx 8 :pid 0} "+")
     (:ws/horiz @{:bc 12 :bl 1 :bp 11
                  :ec 13 :el 1 :ep 12 :id 10 :idx 9 :pid 0} " ")
     (:blob @{:bc 13 :bl 1 :bp 12
              :ec 15 :el 1 :ep 14 :id 11 :idx 10 :pid 0} "1;")]

  (var cursor
    (cc/make-cursor
      id->node
      '(:ws/horiz @{:bc 6 :bl 1 :bp 5
                    :ec 7 :el 1 :ep 6 :id 4 :idx 3 :pid 0} " ")))

  ((cc/right cursor) :node)
  # =>
  '(:blob @{:bc 7 :bl 1 :bp 6
            :ec 8 :el 1 :ep 7 :id 5 :idx 4 :pid 0} "=")

  (set cursor
       (cc/right cursor))

  (cursor :node)
  # =>
  '(:blob @{:bc 7 :bl 1 :bp 6
            :ec 8 :el 1 :ep 7 :id 5 :idx 4 :pid 0} "=")

  )

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (cc/make-infra))

  # populates id->node
  (par "{ 1 + 1; }")
  # =>
  '@[:code @{:bc 1 :bl 1 :bp 0 :ec 11 :el 1 :ep 10 :id 0}
     (:dl/curly @{:bc 1 :bl 1 :bp 0
                  :ec 11 :el 1 :ep 10 :id 8 :idx 0 :pid 0}
                (:ws/horiz @{:bc 2 :bl 1 :bp 1
                             :ec 3 :el 1 :ep 2 :id 1 :idx 0 :pid 8} " ")
                (:blob @{:bc 3 :bl 1 :bp 2
                         :ec 4 :el 1 :ep 3 :id 2 :idx 1 :pid 8} "1")
                (:ws/horiz @{:bc 4 :bl 1 :bp 3
                             :ec 5 :el 1 :ep 4 :id 3 :idx 2 :pid 8} " ")
                (:blob @{:bc 5 :bl 1 :bp 4
                         :ec 6 :el 1 :ep 5 :id 4 :idx 3 :pid 8} "+")
                (:ws/horiz @{:bc 6 :bl 1 :bp 5
                             :ec 7 :el 1 :ep 6 :id 5 :idx 4 :pid 8} " ")
                (:blob @{:bc 7 :bl 1 :bp 6
                         :ec 9 :el 1 :ep 8 :id 6 :idx 5 :pid 8} "1;")
                (:ws/horiz @{:bc 9 :bl 1 :bp 8
                             :ec 10 :el 1 :ep 9 :id 7 :idx 6 :pid 8} " "))]

  (length id->node)
  # =>
  9

  ((cc/df-next (cc/make-cursor id->node)) :node)
  # =>
  '(:dl/curly @{:bc 1 :bl 1 :bp 0
                :ec 11 :el 1 :ep 10 :id 8 :idx 0 :pid 0}
              (:ws/horiz @{:bc 2 :bl 1 :bp 1
                           :ec 3 :el 1 :ep 2 :id 1 :idx 0 :pid 8} " ")
              (:blob @{:bc 3 :bl 1 :bp 2
                       :ec 4 :el 1 :ep 3 :id 2 :idx 1 :pid 8} "1")
              (:ws/horiz @{:bc 4 :bl 1 :bp 3
                           :ec 5 :el 1 :ep 4 :id 3 :idx 2 :pid 8} " ")
              (:blob @{:bc 5 :bl 1 :bp 4
                       :ec 6 :el 1 :ep 5 :id 4 :idx 3 :pid 8} "+")
              (:ws/horiz @{:bc 6 :bl 1 :bp 5
                           :ec 7 :el 1 :ep 6 :id 5 :idx 4 :pid 8} " ")
              (:blob @{:bc 7 :bl 1 :bp 6
                       :ec 9 :el 1 :ep 8 :id 6 :idx 5 :pid 8} "1;")
              (:ws/horiz @{:bc 9 :bl 1 :bp 8
                           :ec 10 :el 1 :ep 9 :id 7 :idx 6 :pid 8} " "))

  (var crs (cc/make-cursor id->node))

  (for i 0 (length id->node)
    (set crs (cc/df-next crs)))

  crs
  # =>
  :back-at-top

  )

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (cc/make-infra))

  (par `printf("animals: %s, %s, %s", "ant", "bee", "cheetah");`)

  ((-> (cc/make-cursor id->node)
       cc/down # starts at :code
       cc/right
       cc/down
       cc/rightmost)
    :node)
  # =>
  '(:str/dq @{:bc 45 :bl 1 :bp 44
              :ec 54 :el 1 :ep 53 :id 11 :idx 9 :pid 12}
            "\"cheetah\"")

  )

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (cc/make-infra))

  (par "int a = 1 + 2;")

  (length id->node)
  # =>
  12

  (var cursor
    (cc/make-cursor id->node))

  (set cursor
       (-> cursor
           cc/down # starts at :code
           cc/rightmost)) # ends at 2;

  ((-> cursor
       cc/left # whitespace
       cc/left) :node)
  # =>
  '(:blob @{:bc 11 :bl 1 :bp 10
            :ec 12 :el 1 :ep 11 :id 9 :idx 8 :pid 0}
          "+")

  )

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (cc/make-infra))

  # populates id->node
  (par
    ``
    int main(int argc, char** argv) {
      return 1 - 1;
    }
    ``)

  (length id->node)
  # =>
  24

  (def init-crs
    (cc/make-cursor id->node))

  (var crs
    (cc/make-cursor id->node))

  (def n
    (min 21
         (dec (length id->node))))

  # n = 23 will yield :back-at-top?
  (for i 0 n
    (set crs (cc/df-next crs)))

  # if n = 23, this won't work because :back-at-top is not a cursor
  (for i 0 n
    (set crs (cc/df-prev crs)))

  (deep= crs init-crs)
  # =>
  true

  )

