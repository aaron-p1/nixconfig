(local {: setup} (require :ibl))

(fn config []
  (setup {:exclude {:filetypes [:help :packer]} :scope {:show_end false}}))

{: config}
