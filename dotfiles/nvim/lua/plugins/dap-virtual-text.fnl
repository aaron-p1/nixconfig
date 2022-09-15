(local {: setup} (require :nvim-dap-virtual-text))

(fn config []
  (setup {:enabled true
          :enabled_commands true
          :highlight_changed_variables true
          :highlight_new_as_changed false
          :show_stop_reason true
          :commented false
          :virt_text_pos :eol
          :all_frames false
          :virt_lines false
          :virt_text_win_col nil}))

{: config}
