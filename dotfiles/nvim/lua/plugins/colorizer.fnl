(local {: setup} (require :colorizer))

(fn config []
  (setup {:filetypes ["*"]
          :user_default_options {:RRGGBBAA true
                                 :AARRGGBB true
                                 :rgb_fn true
                                 :hsl_fn true
                                 :css true
                                 :css_fn true
                                 :tailwind true
                                 :sass {:enable true}}}))

{: config}
