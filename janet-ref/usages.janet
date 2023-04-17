(import ./print :as pr)
(import ./parse/tests :as tests)

(defn thing-usages
  [content &opt limit]
  # extract first set of tests from content
  (def tests
    (tests/extract-first-test-set content))
  (when (empty? tests)
    (break [nil
            "Sorry, didn't find any material to make a quiz from."]))
  (default limit (length tests))
  (def buf @"")
  (with-dyns [*out* buf]
      # question and answer pairs
      (each [ques ans] (array/slice tests 0
                                    (min limit (length tests)))
        (def trimmed-ans (string/trim ans))
        # show the question
        (pr/print-nicely-mono ques)
        (print "# =>")
        (pr/print-nicely-mono ans)
        (print)))
  #
  [true buf])

