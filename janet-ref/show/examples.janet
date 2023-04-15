(import ./misc :as misc)
(import ../parse/tests :as tests)

(defn thing-examples
  [content]
  # extract first set of tests from content
  (def tests
    (tests/extract-first-test-set content))
  (when (empty? tests)
    (break [nil
            "Sorry, didn't find any material to make a quiz from."]))
  (def buf @"")
  (def res
    (with-dyns [*out* buf]
      # choose a question and answer pair
      (each [ques ans] tests
        (def trimmed-ans (string/trim ans))
        # show the question
        (misc/print-nicely ques)
        (print "# =>")
        (misc/print-nicely ans)
        (print))))
  #
  [res buf])

