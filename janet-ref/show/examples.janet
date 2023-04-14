(import ./misc :as misc)
(import ../parse/tests :as tests)

(defn thing-examples
  [content]
  # extract first set of tests from content
  (def tests
    (tests/extract-first-test-set content))
  (when (empty? tests)
    (print "Sorry, didn't find any material to make a quiz from.")
    (break nil))
  # choose a question and answer pair
  (each [ques ans] tests
    (def trimmed-ans (string/trim ans))
    # show the question
    (misc/print-nicely ques)
    (print "# =>")
    (misc/print-nicely ans)
    (print)))

