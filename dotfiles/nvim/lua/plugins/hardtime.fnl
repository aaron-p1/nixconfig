(local {: setup} (require :hardtime))

(fn config []
  (setup {:disabled_keys {:<Up> [] :<Down> []}}))

{: config}
