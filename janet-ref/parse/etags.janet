# TAGS (emacs tags file format)

```

path,line

path,line
search-string,idline,offset-from-start
...
search-string,idline,offset-from-start

```

```
 - 0x01
 - 0x0c
 - 0x7f
```

# SOH - start of heading
(def start-of-heading
  (string/from-bytes 0x01))

# FF - form feed
(def form-feed
  (string/from-bytes 0x0C))

# DEL - delete
(def delete
  (string/from-bytes 0x7F))

(def etags-grammar
  ~{:main (sequence (any (sequence :section-sep :section)) -1)
    :section-sep (sequence ,form-feed :eol)
    :section (cmt (sequence :file-line (any :tag-line))
                  ,(fn [path & rest]
                     (merge ;(keep (fn [m]
                                     # each m has only one key, the id
                                     (when-let [id (first (keys m))
                                                val (get m id)]
                                       (put m
                                            id (array/push val path))))
                                   rest))))
    :file-line (sequence (capture :path) "," :d+ :eol)
    # \r, \n are here to bound the matching to the current line
    :path (some (if-not (set ",\r\n") 1))
    :tag-line (cmt (sequence (capture :search-str)
                             :tag-line-sep-1
                             (capture :id)
                             :tag-line-sep-2
                             (number :d+)
                             ","
                             (number :d+)
                             :eol)
                   ,|@{$1 @[$2 $3 $0]})
    # \r, \n are here to bound the matching to the current line
    :search-str (some (if-not (choice :tag-line-sep-1 :eol) 1))
    # \r, \n are here to bound the matching to the current line
    :id (some (if-not (choice :tag-line-sep-2 :eol) 1))
    :eol (choice "\r\n" "\r" "\n")
    :tag-line-sep-1 ,delete
    :tag-line-sep-2 ,start-of-heading})

(comment

  (def etags
    ```
    
    src/core/pp.c,0
    
    src/core/tuple.c,275
    JANET_CORE_FN(cfun_tuple_brackets,tuple/brackets58,2136
    JANET_CORE_FN(cfun_tuple_slice,tuple/slice66,2433
    JANET_CORE_FN(cfun_tuple_type,tuple/type80,3259
    JANET_CORE_FN(cfun_tuple_sourcemap,tuple/sourcemap96,3928
    JANET_CORE_FN(cfun_tuple_setmap,tuple/setmap108,4432
    
    src/core/regalloc.c,0
    
    src/core/specials.c,0

    ```)

  (peg/match etags-grammar etags)
  # =>
  '@[@{}
     @{"tuple/brackets"
       @[58 2136 "JANET_CORE_FN(cfun_tuple_brackets," "src/core/tuple.c"]
       "tuple/setmap"
       @[108 4432 "JANET_CORE_FN(cfun_tuple_setmap," "src/core/tuple.c"]
       "tuple/slice"
       @[66 2433 "JANET_CORE_FN(cfun_tuple_slice," "src/core/tuple.c"]
       "tuple/sourcemap"
       @[96 3928 "JANET_CORE_FN(cfun_tuple_sourcemap," "src/core/tuple.c"]
       "tuple/type"
       @[80 3259 "JANET_CORE_FN(cfun_tuple_type," "src/core/tuple.c"]}
     @{}
     @{}]

  )
