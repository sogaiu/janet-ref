(import ./highlight/color :as color)
(import ./highlight/mono :as mono)
(import ./highlight/rgb :as rgb)
(import ./highlight/theme :as theme)

(defn configure
  []
  # width
  # XXX: tput cols can give a number for this, but not multi-platform?
  (setdyn :jref-width 68)
  # color
  (let [color-level (os/getenv "JREF_COLOR")
        # XXX: tput colors more portable?
        color-term (os/getenv "COLORTERM")]
    # XXX: not ready for prime time, so insist JREF_COLOR is
    #      set for anything to happen
    (if color-level
      (cond
        (or (= "rgb" color-level)
            #(= "truecolor" color-term)
            false)
        (do
          (setdyn :jref-hl-prin rgb/rgb-prin)
          (setdyn :jref-hl-str rgb/rgb-str)
          (setdyn :jref-separator-color rgb/rgb-separator-color)
          (setdyn :jref-theme theme/rgb-theme))
        #
        (or (= "color" color-level)
            (= "16" color-term))
        (do
          (setdyn :jref-hl-prin color/color-prin)
          (setdyn :jref-hl-str color/color-str)
          (setdyn :jref-separator-color color/color-separator-color)
          (setdyn :jref-theme theme/color-theme))
        #
        (do
          (setdyn :jref-hl-prin mono/mono-prin)
          (setdyn :jref-hl-str mono/mono-str)
          (setdyn :jref-separator-color mono/mono-separator-color)
          (setdyn :jref-theme theme/mono-theme)))
      # no color
      (do
        (setdyn :jref-hl-prin mono/mono-prin)
        (setdyn :jref-hl-str mono/mono-str)
        (setdyn :jref-separator-color mono/mono-separator-color)
        (setdyn :jref-theme theme/mono-theme)))))

