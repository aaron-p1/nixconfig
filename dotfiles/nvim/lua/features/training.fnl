(local {: deep_equal
        : notify
        :api {: nvim_buf_clear_namespace
              : nvim_buf_set_extmark
              : nvim_clear_autocmds
              : nvim_create_augroup
              : nvim_create_autocmd
              : nvim_create_namespace
              : nvim_create_user_command
              : nvim_get_current_buf
              : nvim_set_hl
              : nvim_win_get_cursor}
        :fn {: line : getline : strdisplaywidth}
        :log {:levels {: ERROR}}} vim)

(local namespace (nvim_create_namespace :Training))
(local augroup (nvim_create_augroup :Training {:clear true}))

(var ?target-position nil)

(nvim_set_hl 0 :TrainingTarget {:fg "#ffffff" :bg "#ff0000" :default true})

(lambda get-new-position [first-line last-line]
  (let [line (math.random first-line last-line)
        line-content (getline (+ line 1))
        max-col (strdisplaywidth line-content)
        empty-line? (= max-col 0)
        col (if empty-line? 0 (math.random 0 (- max-col 1)))]
    (if (deep_equal ?target-position [line col])
        (get-new-position first-line last-line)
        (values [line col] empty-line?))))

(lambda place-target []
  (nvim_buf_clear_namespace 0 namespace 0 -1)
  (let [first-line (- (line :w0) 1)
        last-line (- (line :w$) 1)
        (new-position empty-line?) (get-new-position first-line last-line)
        [line col] new-position
        ext-data {:strict false
                  :end_col (+ col 1)
                  :hl_group :TrainingTarget
                  :virt_text (if empty-line? [[:X :TrainingTarget]])
                  :virt_text_pos (if empty-line? :overlay)}]
    (nvim_buf_set_extmark 0 namespace line col ext-data)
    (set ?target-position new-position)))

(lambda check-cursor-position []
  (let [[line col] (nvim_win_get_cursor 0)]
    (if (deep_equal ?target-position [(- line 1) col])
        (place-target))))

(lambda stop-training [bufnr]
  (nvim_clear_autocmds {:group augroup})
  (nvim_buf_clear_namespace bufnr namespace 0 -1)
  (set ?target-position nil))

(lambda start-training []
  (let [bufnr (nvim_get_current_buf)]
    (place-target)
    (nvim_create_autocmd :CursorMoved
                         {:group augroup :callback check-cursor-position})
    (nvim_create_autocmd :WinLeave
                         {:group augroup :callback #(stop-training bufnr)})))

(lambda handle-command [{:fargs [command]}]
  (match command
    :start (start-training)
    :stop (stop-training (nvim_get_current_buf))
    _ (notify "Unknown command" ERROR)))

(fn setup []
  (nvim_create_user_command :Training handle-command
                            {:nargs 1 :complete #[:start :stop]}))

{: setup}
