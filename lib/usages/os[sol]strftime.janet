(comment

  (os/strftime "%a" 0)
  # =>
  "Thu"

  (os/strftime "%A" 0)
  # =>
  "Thursday"

  (os/strftime "%b" 0)
  # =>
  "Jan"

  (os/strftime "%B" 0)
  # =>
  "January"

  (os/strftime "%c" 0)
  # =>
  "Thu Jan  1 00:00:00 1970"

  (os/strftime "%d" 0)
  # =>
  "01"

  (os/strftime "%H" 0)
  # =>
  "00"

  (os/strftime "%I" 0)
  # =>
  "12"

  (os/strftime "%j" 0)
  # =>
  "001"

  (os/strftime "%m" 0)
  # =>
  "01"

  (os/strftime "%M" 0)
  # =>
  "00"

  (os/strftime "%p" 0)
  # =>
  "AM"

  (os/strftime "%S" 0)
  # =>
  "00"

  (os/strftime "%U" 0)
  # =>
  "00"

  (os/strftime "%w" 0)
  # =>
  "4"

  (os/strftime "%W" 0)
  # =>
  "00"

  (os/strftime "%x" 0)
  # =>
  "01/01/70"

  (os/strftime "%X" 0)
  # =>
  "00:00:00"

  (os/strftime "%y" 0)
  # =>
  "70"

  (os/strftime "%Y" 0)
  # =>
  "1970"

  (os/strftime "%%")
  # =>
  "%"

  )

#  (os/strftime "%Z" 0)
#  "GMT"

```
  Some conversion specifications can be modified by preceding the conver‐
  sion specifier character by the E or O modifier to indicate that an al‐
  ternative format should be used.  If the alternative format or specifi‐
  cation  does  not exist for the current locale, the behavior will be as
  if the unmodified conversion specification were used. (SU)  The  Single
  UNIX  Specification  mentions  %Ec,  %EC, %Ex, %EX, %Ey, %EY, %Od, %Oe,
  %OH, %OI, %Om, %OM, %OS, %Ou, %OU, %OV, %Ow, %OW, %Oy, where the effect
  of the O modifier is to use alternative numeric symbols (say, roman nu‐
  merals), and that of the E modifier is to use a locale-dependent alter‐
  native  representation.   The  rules governing date representation with
  the E modifier can be obtained by supplying ERA as  an  argument  to  a
  nl_langinfo(3).   One example of such alternative forms is the Japanese
  era calendar scheme in the ja_JP glibc locale.
```

#  (os/strftime "%E" 0)
#  "%E"

#  (os/strftime "%O")
#  "%O"

#  (os/strftime "%+")
#  "%+"
