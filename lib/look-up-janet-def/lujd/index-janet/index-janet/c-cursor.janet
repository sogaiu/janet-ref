(import ./c-peg :as cp)
# to make generic cursor functions available
(import ./cursor :prefix "" :export true)

(defn make-infra
  []
  (init-infra cp/make-grammar))

(comment

  (def {:grammar loc-grammar
        :issuer issue-id
        :node-table id->node
        :loc-table loc->id
        :reset reset}
    (make-infra))

  (reset)

  (get (peg/match loc-grammar "1") 3)
  # =>
  '(:blob @{:bc 1 :bl 1 :bp 0
            :ec 2 :el 1 :ep 1
            :id 1}
          "1")

  (get (peg/match loc-grammar "[1]") 3)
  # =>
  '(:dl/square @{:bc 1 :bl 1 :bp 0
                 :ec 4 :el 1 :ep 3
                 :id 3}
               (:blob @{:bc 2 :bl 1 :bp 1
                        :ec 3 :el 1 :ep 2
                        :id 2 :idx 0 :pid 3}
                      "1"))

  id->node
  # =>
  '@{1
     (:blob @{:bc 1 :bl 1 :bp 0 :ec 2 :el 1 :ep 1 :id 1} "1")
     2
     (:blob @{:bc 2 :bl 1 :bp 1
              :ec 3 :el 1 :ep 2
              :id 2 :idx 0 :pid 3}
            "1")
     3
     (:dl/square @{:bc 1 :bl 1 :bp 0 :ec 4 :el 1 :ep 3 :id 3}
                 (:blob @{:bc 2 :bl 1 :bp 1
                          :ec 3 :el 1 :ep 2
                          :id 2 :idx 0 :pid 3}
                        "1"))}

  loc->id
  # =>
  '@{{:bc 2 :bl 1 :bp 1 :ec 3 :el 1 :ep 2} 2
     {:bc 1 :bl 1 :bp 0 :ec 4 :el 1 :ep 3} 3
     {:bc 1 :bl 1 :bp 0 :ec 2 :el 1 :ep 1} 1}

  )



