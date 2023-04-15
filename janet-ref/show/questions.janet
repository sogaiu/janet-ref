(import ./misc :as misc)
(import ../parse/question :as qu)
(import ../parse/tests :as tests)
(import ../random :as rnd)

(defn handle-eval-failure
  [resp e]
  (print "Sorry, failed to evaluate your answer.")
  (print)
  (print "The error I got was:")
  (print)
  (printf "%p" e)
  (print)
  (print "I tried to evaluate the following:")
  (print)
  (print resp))

(defn handle-eval-comparison
  [prog-ans user-ans]
  (if (deep= prog-ans user-ans)
    (do
      (print "Nice, our answers both evaluate to:")
      (print)
      (misc/print-nicely (string/format "%m" prog-ans))
      true)
    (do
      (printf "Sorry, our answers evaluate differently.")
      (print)
      (print "My answer evaluates to:")
      (print)
      (misc/print-nicely (string/format "%m" prog-ans))
      (print)
      (print "Your answer evaluates to:")
      (print)
      (misc/print-nicely (string/format "%m" user-ans))
      false)))

(defn handle-plain-response
  [ans resp]
  (print "My answer is:")
  (print)
  (misc/print-nicely ans)
  (print)
  (print "Your answer is:")
  (print)
  (misc/print-nicely resp)
  (print)
  (when (deep= ans resp)
    (print "Yay, the answers agree :)")
    (break true))
  (print "Our answers differ, but perhaps yours works too.")
  (print)
  (try
    (let [evaled-ans (eval-string ans)
          result (eval-string resp)]
      (handle-eval-comparison evaled-ans result))
    ([e]
      (handle-eval-failure resp e)
      false)))

(defn handle-want-to-quit
  [buf]
  (when (empty? (string/trim buf))
    (print "Had enough?  Perhaps on another occasion then.")
    #
    true))

(defn validate-response
  [buf]
  (try
    (do
      (parse buf)
      (string/trim buf))
    ([e]
      (print)
      (printf "Sorry, I didn't understand your response: %s"
              (string/trim buf))
      (print)
      (print "I got the following error:")
      (print)
      (printf "%p" e)
      nil)))

(defn thing-plain-quiz
  [content]
  # extract first set of tests from content
  (def tests
    (tests/extract-first-test-set content))
  (when (empty? tests)
    (print "Sorry, didn't find any material to make a quiz from.")
    (break nil))
  # choose a question and answer pair
  (let [[ques ans] (rnd/choose tests)
        trimmed-ans (string/trim ans)]
    (print "# What does the following evaluate to?")
    (print)
    # show the question
    (misc/print-nicely ques)
    (print "# =>")
    # ask for an answer
    (def buf
      (getline ""))
    (when (handle-want-to-quit buf)
      (break nil))
    # does the response make some sense?
    (def resp
      (validate-response buf))
    (unless resp
      (break nil))
    # improve perceptibility
    (print)
    (misc/print-separator)
    (print)
    #
    (handle-plain-response trimmed-ans resp)))

(defn handle-fill-in-response
  [ques blank-ques blanked-item ans resp]
  (print "One complete picture is: ")
  (print)
  (misc/print-nicely ques)
  (print "# =>")
  (misc/print-nicely ans)
  (print)
  (print "So one value that works is:")
  (print)
  (misc/print-nicely blanked-item)
  (print)
  (print "Your answer is:")
  (print)
  (misc/print-nicely resp)
  (print)
  (when (deep= blanked-item resp)
    (print "Yay, the answers agree :)")
    (break true))
  (print "Our answers differ, but perhaps yours works too.")
  (print)
  (let [indeces (string/find-all "_" blank-ques)
        head-idx (first indeces)
        tail-idx (last indeces)]
    # XXX: cheap method -- more accurate would be to use zippers
    (def resp-code
      (string (string/slice blank-ques 0 head-idx)
              resp
              (string/slice blank-ques (inc tail-idx))))
    (try
      (let [evaled-ans (eval-string ans)
            result (eval-string resp-code)]
        (handle-eval-comparison evaled-ans result))
      ([e]
        (handle-eval-failure resp-code e)
        false))))

(defn thing-fill-in-quiz
  [content]
  # extract first set of tests from content
  (def test-zloc-pairs
    (tests/extract-first-test-set-zlocs content))
  (when (empty? test-zloc-pairs)
    (print "Sorry, didn't find any material to make a quiz from.")
    (break nil))
  # choose a question and answer, then make a blanked question
  (let [[ques-zloc ans-zloc] (rnd/choose test-zloc-pairs)
        [blank-ques-zloc blanked-item] (qu/rewrite-test-zloc ques-zloc)]
    # XXX: a cheap work-around...evidence of a deeper issue?
    (unless blank-ques-zloc
      (print "Sorry, drew a blank...take a deep breath and try again?")
      (break nil))
    (let [ques (tests/indent-node-gen ques-zloc)
          blank-ques (tests/indent-node-gen blank-ques-zloc)
          trimmed-ans (string/trim (tests/indent-node-gen ans-zloc))]
      # show the question
      (misc/print-nicely blank-ques)
      (print "# =>")
      (misc/print-nicely trimmed-ans)
      (print)
      # ask for an answer
      (def buf
        (getline "What value could work in the blank? "))
      (when (handle-want-to-quit buf)
        (break nil))
      # does the response make some sense?
      (def resp
        (validate-response buf))
      (unless resp
        (break nil))
      # improve perceptibility
      (print)
      (misc/print-separator)
      (print)
      #
      (handle-fill-in-response ques blank-ques blanked-item
                               trimmed-ans resp))))

(defn thing-quiz
  [content]
  (def quiz-fn
    (rnd/choose [thing-plain-quiz
                 thing-fill-in-quiz]))
  (quiz-fn content))

