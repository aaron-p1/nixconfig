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
      (kset :n :<Leader>er eval-lua {:buffer bufnr :desc "Eval lua"}))))

(lambda new [new-win-cmd ?ft]
  (ui.input {:prompt "Buffer name 'scratch - <>'"
             :default :unnamed
             :center true}
            #(if $1 (create (.. "scratch - " $1) new-win-cmd ?ft))))

(fn setup []
  ;; normal
  (kset :n :<Leader>css #(new :split) {:desc :Horizontal})
  (kset :n :<Leader>csv #(new :vsplit) {:desc :Vertical})
  (kset :n :<Leader>cst #(new "tab split") {:desc :Tab})
  ;; lua
  (kset :n :<Leader>csls #(new :split :lua) {:desc :Horizontal})
  (kset :n :<Leader>cslv #(new :vsplit :lua) {:desc :Vertical})
  (kset :n :<Leader>cslt #(new "tab split" :lua) {:desc :Tab}))

{: setup}
