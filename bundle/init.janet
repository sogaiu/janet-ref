(defn install
  [manifest &]
  (def bin-name "jref")
  #
  (def wants-bs {:windows true :mingw true})
  (def bs-land? (get wants-bs (os/which)))
  (def sep (if bs-land? `\` "/"))
  #
  (def bin-path
    (string/format `bin%s%s` sep bin-name))
  (def bin-full-path
    (string/format `%s%s%s` (dyn *syspath*) sep bin-path))
  #
  (bundle/add-bin manifest bin-path)
  #
  (when bs-land?
    (def bat-content
      # jpm and janet-pm have bits like this
      # https://github.com/microsoft/terminal/issues/217#issuecomment-737594785
      (string "@echo off\r\n"
              "goto #_undefined_# 2>NUL || "
              `title %COMSPEC% & janet "` bin-full-path `" %*`))
    # XXX: not so nice approach?  do stuff in _build?
    (def bat-name (string/format "%s.bat" bin-name))
    (defer (os/rm bat-name)
      (spit bat-name bat-content)
      (bundle/add-bin manifest bat-name)))
  #
  (def prefix (get-in manifest [:info :source :prefix]))
  (def srcs (get-in manifest [:info :source :files] []))
  (bundle/add-directory manifest prefix)
  (each src srcs
    (bundle/add manifest src (string prefix sep src))))

