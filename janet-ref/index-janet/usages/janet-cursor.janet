(import ../index-janet/janet-cursor :as jc)

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (jc/make-infra))

  (par "(+ 1 1)")
  # =>
  '@[:code @{:bc 1 :bl 1 :bp 0 :ec 8 :el 1 :ep 7 :id 0}
     (:dl/round
       @{:bc 1 :bl 1 :bp 0 :ec 8 :el 1 :ep 7 :id 6 :idx 0 :pid 0}
       (:blob @{:bc 2 :bl 1 :bp 1
                :ec 3 :el 1 :ep 2 :id 1 :idx 0 :pid 6} "+")
       (:ws/horiz @{:bc 3 :bl 1 :bp 2
                    :ec 4 :el 1 :ep 3 :id 2 :idx 1 :pid 6} " ")
       (:blob @{:bc 4 :bl 1 :bp 3
                :ec 5 :el 1 :ep 4 :id 3 :idx 2 :pid 6} "1")
       (:ws/horiz @{:bc 5 :bl 1 :bp 4
                    :ec 6 :el 1 :ep 5 :id 4 :idx 3 :pid 6} " ")
       (:blob @{:bc 6 :bl 1 :bp 5
                :ec 7 :el 1 :ep 6 :id 5 :idx 4 :pid 6} "1"))]

  id->node
  # =>
  '@{0
     @[:code @{:bc 1 :bl 1 :bp 0 :ec 8 :el 1 :ep 7 :id 0}
       (:dl/round @{:bc 1 :bl 1 :bp 0
                    :ec 8 :el 1 :ep 7 :id 6 :idx 0 :pid 0}
                  (:blob @{:bc 2 :bl 1 :bp 1
                           :ec 3 :el 1 :ep 2 :id 1 :idx 0 :pid 6} "+")
                  (:ws/horiz @{:bc 3 :bl 1 :bp 2
                               :ec 4 :el 1 :ep 3 :id 2 :idx 1 :pid 6} " ")
                  (:blob @{:bc 4 :bl 1 :bp 3
                           :ec 5 :el 1 :ep 4 :id 3 :idx 2 :pid 6} "1")
                  (:ws/horiz @{:bc 5 :bl 1 :bp 4
                               :ec 6 :el 1 :ep 5 :id 4 :idx 3 :pid 6} " ")
                  (:blob @{:bc 6 :bl 1 :bp 5
                           :ec 7 :el 1 :ep 6 :id 5 :idx 4 :pid 6} "1"))]
     1
     (:blob @{:bc 2 :bl 1 :bp 1
              :ec 3 :el 1 :ep 2 :id 1 :idx 0 :pid 6} "+")
     2
     (:ws/horiz @{:bc 3 :bl 1 :bp 2
                  :ec 4 :el 1 :ep 3 :id 2 :idx 1 :pid 6} " ")
     3
     (:blob @{:bc 4 :bl 1 :bp 3
              :ec 5 :el 1 :ep 4 :id 3 :idx 2 :pid 6} "1")
     4
     (:ws/horiz @{:bc 5 :bl 1 :bp 4
                  :ec 6 :el 1 :ep 5 :id 4 :idx 3 :pid 6} " ")
     5
     (:blob @{:bc 6 :bl 1 :bp 5 :ec 7 :el 1 :ep 6 :id 5 :idx 4 :pid 6} "1")
     6
     (:dl/round @{:bc 1 :bl 1 :bp 0 :ec 8 :el 1 :ep 7 :id 6 :idx 0 :pid 0}
                (:blob @{:bc 2 :bl 1 :bp 1
                         :ec 3 :el 1 :ep 2 :id 1 :idx 0 :pid 6} "+")
                (:ws/horiz @{:bc 3 :bl 1 :bp 2
                             :ec 4 :el 1 :ep 3 :id 2 :idx 1 :pid 6} " ")
                (:blob @{:bc 4 :bl 1 :bp 3
                         :ec 5 :el 1 :ep 4 :id 3 :idx 2 :pid 6} "1")
                (:ws/horiz @{:bc 5 :bl 1 :bp 4
                             :ec 6 :el 1 :ep 5 :id 4 :idx 3 :pid 6} " ")
                (:blob @{:bc 6 :bl 1 :bp 5
                         :ec 7 :el 1 :ep 6 :id 5 :idx 4 :pid 6} "1"))}

  )

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (jc/make-infra))

  (par "(+ 1 1)")

  (var cursor
    (jc/make-cursor
      id->node
      '(:ws/horiz @{:bc 3 :bl 1 :ec 4 :el 1 :id 2 :idx 1 :pid 6} " ")))

  ((jc/right cursor) :node)
  # =>
  '(:blob @{:bc 4 :bl 1 :bp 3
            :ec 5 :el 1 :ep 4
            :id 3 :idx 2 :pid 6}
          "1")

  (set cursor
       (jc/right cursor))

  (cursor :node)
  # =>
  '(:blob @{:bc 4 :bl 1 :bp 3
            :ec 5 :el 1 :ep 4
            :id 3 :idx 2 :pid 6}
          "1")

  ((jc/up cursor) :node)
  # =>
  '(:dl/round
     @{:bc 1 :bl 1 :bp 0
       :ec 8 :el 1 :ep 7 :id 6 :idx 0 :pid 0}
     (:blob @{:bc 2 :bl 1 :bp 1
              :ec 3 :el 1 :ep 2 :id 1 :idx 0 :pid 6} "+")
     (:ws/horiz @{:bc 3 :bl 1 :bp 2
                  :ec 4 :el 1 :ep 3 :id 2 :idx 1 :pid 6} " ")
     (:blob @{:bc 4 :bl 1 :bp 3
              :ec 5 :el 1 :ep 4 :id 3 :idx 2 :pid 6} "1")
     (:ws/horiz @{:bc 5 :bl 1 :bp 4
                  :ec 6 :el 1 :ep 5 :id 4 :idx 3 :pid 6} " ")
     (:blob @{:bc 6 :bl 1 :bp 5
              :ec 7 :el 1 :ep 6 :id 5 :idx 4 :pid 6} "1"))

  ((-> (jc/make-cursor id->node (get id->node 6))
       jc/down)
    :node)
  # =>
  '(:blob @{:bc 2 :bl 1 :bp 1
            :ec 3 :el 1 :ep 2
            :id 1 :idx 0 :pid 6}
          "+")

  )

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (jc/make-infra))

  # populates id->node
  (par "(+ 1 1)")

  (length id->node)
  # =>
  7

  ((jc/df-next (jc/make-cursor id->node)) :node)
  # =>
  '(:dl/round
     @{:bc 1 :bl 1 :bp 0
       :ec 8 :el 1 :ep 7 :id 6 :idx 0 :pid 0}
     (:blob @{:bc 2 :bl 1 :bp 1
              :ec 3 :el 1 :ep 2 :id 1 :idx 0 :pid 6} "+")
     (:ws/horiz @{:bc 3 :bl 1 :bp 2
                  :ec 4 :el 1 :ep 3 :id 2 :idx 1 :pid 6} " ")
     (:blob @{:bc 4 :bl 1 :bp 3
              :ec 5 :el 1 :ep 4 :id 3 :idx 2 :pid 6} "1")
     (:ws/horiz @{:bc 5 :bl 1 :bp 4
                  :ec 6 :el 1 :ep 5 :id 4 :idx 3 :pid 6} " ")
     (:blob @{:bc 6 :bl 1 :bp 5
              :ec 7 :el 1 :ep 6 :id 5 :idx 4 :pid 6} "1"))

  (var crs (jc/make-cursor id->node))

  (for i 0 (length id->node)
    (set crs (jc/df-next crs)))

  crs
  # =>
  :back-at-top

  )

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (jc/make-infra))

  # populates id->node
  (par "(defn a [x] (+ x 1) (/ x 2))")

  (length id->node)
  # =>
  22

  (var crs
    (jc/make-cursor id->node))

  (for i 0 (length id->node)
    (set crs (jc/df-next crs)))

  crs
  # =>
  :back-at-top

  )

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (jc/make-infra))

  (par "[1 2 3 8 9 0]")

  ((-> (jc/make-cursor id->node)
       jc/down # starts at :code
       jc/down
       jc/rightmost)
    :node)
  # =>
  '(:blob @{:bc 12 :bl 1 :bp 11
            :ec 13 :el 1 :ep 12
            :id 11 :idx 10 :pid 12}
          "0")

  )

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (jc/make-infra))

  (par "[:a :b :c]")

  (length id->node)
  # =>
  7

  (var cursor
    (jc/make-cursor id->node))

  (set cursor
       (-> cursor
           jc/down # starts at :code
           jc/down
           jc/rightmost))

  ((jc/left cursor) :node)
  # =>
  '(:ws/horiz @{:bc 7 :bl 1 :bp 6
                :ec 8 :el 1 :ep 7
                :id 4 :idx 3 :pid 6}
              " ")

  )

(comment

  (def {:grammar loc-grammar
        :node-table id->node
        :parse par}
    (jc/make-infra))

  # populates id->node
  (par "(defn a [x] (+ x 1) (/ x 2))")

  (length id->node)
  # =>
  22

  (def init-crs
    (jc/make-cursor id->node))

  (var crs
    (jc/make-cursor id->node))

  (def n
    (min 21
         (dec (length id->node))))

  # n = 22 will yield :back-at-top
  (for i 0 n
    (set crs (jc/df-next crs)))

  # if n = 22, this won't work because :back-at-top is not a cursor
  (for i 0 n
    (set crs (jc/df-prev crs)))

  (deep= crs init-crs)
  # =>
  true

  )

