(local {: ui
        : cmd
        :api {: nvim_buf_get_lines
              : nvim_echo
              : nvim_get_current_win
              : nvim_create_buf
              : nvim_buf_set_name
              : nvim_win_set_buf
              : nvim_buf_set_option}
        :keymap {:set kset}} vim)

(local {:register wk-register} (require :plugins.which-key))

(fn eval-lua []
  (let [lines (nvim_buf_get_lines 0 0 -1 false)
        content (table.concat lines "\n")
        func (match (loadstring content)
               (nil err) #(nvim_echo [[err :ErrorMsg]] true {})
               f f)]
    (func)))

(lambda create [name new-win-cmd ?ft]
  (cmd new-win-cmd)
  (let [winnr (nvim_get_current_win)
        bufnr (nvim_create_buf true true)]
    (nvim_buf_set_name bufnr name)
    (nvim_win_set_buf winnr bufnr)
    (when ?ft
      (nvim_buf_set_option bufnr :filetype ?ft))
    (when (= ?ft :lua)
      (kset :n :<LocalLeader>r eval-lua {:buffer bufnr :desc "Eval lua"}))))

(lambda new [new-win-cmd ?ft]
  (ui.input {:prompt "Buffer name 'scratch - <>'"
             :default :unnamed
             :center true}
            #(if $1 (create (.. "scratch - " $1) new-win-cmd ?ft))))

(fn setup []
  ;; plain
  (kset :n :<Leader>csss #(new :split) {:desc :Horizontal})
  (kset :n :<Leader>cssv #(new :vsplit) {:desc :Vertical})
  (kset :n :<Leader>csst #(new "tab split") {:desc :Tab})
  ;; lua
  (kset :n :<Leader>csls #(new :split :lua) {:desc :Horizontal})
  (kset :n :<Leader>cslv #(new :vsplit :lua) {:desc :Vertical})
  (kset :n :<Leader>cslt #(new "tab split" :lua) {:desc :Tab})
  (wk-register {:prefix :<Leader>c
                :map {:s {:name :Scratch :s {:name :Plain} :l {:name :Lua}}}}))

{: setup}
