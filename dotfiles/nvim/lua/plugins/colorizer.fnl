(fn config []
  (local c (require :colorizer))
  (c.setup ["*"] {:css true :css_fn true}))

{: config}
