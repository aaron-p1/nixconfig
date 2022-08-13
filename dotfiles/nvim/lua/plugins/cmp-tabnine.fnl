(fn config []
  (local tn (require :cmp_tabnine.config))
  (tn:setup {:max_lines 1000 :max_num_results 5 :sort true}))

{: config}
