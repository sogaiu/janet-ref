(comment

  (number? 1)
  # =>
  true

  (number? 2.0)
  # =>
  true

  (number? 2e-1)
  # =>
  true

  (number? 0xF_F__F___F____)
  # =>
  true

  (number? 3r01&02)
  # =>
  true

  (number? 2r0101010001)
  # =>
  true

  (number? 2_3_1__._1_2_e-1)
  # =>
  true

  (number? 0x09.1F)
  # =>
  true

  (number? 1_3__0890__100__)
  # =>
  true

  (number? 0x0_9_.1_f__)
  # =>
  true

  (number? -0xFF)
  # =>
  true

  (number? -36r20)
  # =>
  true

  (number? 1E9)
  # =>
  true

  (number? -2.71828)
  # =>
  true

  (number? 0xaB)
  # =>
  true

  (number? 3e8)
  # =>
  true

  (number? math/nan)
  # =>
  true

  (number? (/ 0 0))
  # =>
  true

  (number? (inc math/nan))
  # =>
  true

  (number? (dec math/nan))
  # =>
  true

  (number? (/ math/nan math/nan))
  # =>
  true

  (number? (* 0 math/nan))
  # =>
  true

  (number? nil)
  # =>
  false

  )
