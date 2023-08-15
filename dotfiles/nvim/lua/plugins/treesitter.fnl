(local {:api {: nvim_buf_get_lines}
        :treesitter {:language {:register ts-register}}} vim)

(local {: any} (require :helper))

(local {: setup} (require :nvim-treesitter.configs))

(fn config []
  (setup {:ensure_installed :all
          :highlight {:enable true}
          :indent {:enable true}
          :autotag {:enable true :filetypes [:html :xml :blade :vue]}})
  (ts-register :yaml :yaml.docker-compose))

{: config}
