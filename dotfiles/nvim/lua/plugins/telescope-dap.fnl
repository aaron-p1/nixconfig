(local {: load_extension} (require :telescope))

(fn config []
  (load_extension :dap))

{: config}
