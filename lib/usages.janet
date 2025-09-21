(import ./print :as pr)
(import ./parse/tests :as tests)

(defn all-file-names
  []
  (let [[file-path _]
        (module/find "janet-ref/lib/usages/0.all-the-things")]
    (when file-path
      (let [dir-path
            (string/slice file-path 0
                          (last (string/find-all "/" file-path)))]
        (unless (os/stat dir-path)
          (errorf "Unexpected directory non-existence:" dir-path))
        #
        (os/dir dir-path)))))

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

