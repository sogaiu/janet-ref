(import ../highlight/highlight :as hl)
(import ../jandent/indent)
(import ./misc :as misc)
(import ../parse/tests :as tests)
(import ../random :as rnd)

(defn print-nicely
  [expr-str]
  (let [buf (hl/colorize (indent/format expr-str))]
    (each line (string/split "\n" buf)
      (print line))))

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

(defn handle-plain-response
  [ans resp]
  (print)
  (print "My answer is:")
  (print)
  (print-nicely ans)
  (print)
  (print "Your answer is:")
  (print)
  (print-nicely resp)
  (print)
  (when (deep= ans resp)
    (print "Yay, our answers agree :)")
    (break true))
  (print "Our answers differ, but perhaps yours works too.")
  (print)
  (try
    (let [result (eval-string resp)
          evaled-ans (eval-string ans)]
      (if (deep= result evaled-ans)
        (do
          (printf "Nice, our answers both evaluate to: %M"
                  evaled-ans)
          true)
        (do
          (printf "Sorry, your answer evaluates to: %M" result)
          false)))
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
    # show the question
    (print-nicely ques)
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
  (print)
  (print "One complete picture is: ")
  (print)
  (print-nicely ques)
  (print "# =>")
  (print-nicely ans)
  (print)
  (print "So one value that works is:")
  (print)
  (print-nicely blanked-item)
  (print)
  (print "Your answer is:")
  (print)
  (print-nicely resp)
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
      (let [result (eval-string resp-code)
            evaled-ans (eval-string ans)]
        (if (deep= result evaled-ans)
          (do
            (printf "Nice, our answers both evaluate to: %M"
                    evaled-ans)
            true)
          (do
            (printf "Sorry, our answers evaluate differently.")
            (print)
            (printf "My answer evaluates to: %M" result)
            (print)
            (printf "Your answer evaluates to: %M" evaled-ans)
            false)))
      ([e]
        (handle-eval-failure resp-code e)
        false))))

(defn thing-quiz
  [content]
  (def quiz-fn
    (rnd/choose [thing-plain-quiz]))
  (quiz-fn content))

