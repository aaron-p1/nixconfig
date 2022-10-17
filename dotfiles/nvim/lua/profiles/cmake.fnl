(local {: env
        : ui
        : schedule
        : tbl_extend
        :api {: nvim_buf_set_option
              : nvim_buf_get_lines
              : nvim_win_is_valid
              : nvim_get_current_win
              : nvim_buf_delete
              : nvim_win_close
              : nvim_win_get_buf
              : nvim_create_autocmd}
        :fn {: mkdir : shellescape}
        :cmd {: edit}
        :keymap {:set kset}} vim)

(local {: map : find :open-win {:hor w-hor :ver w-ver :tab w-tab}}
       (require :helper))

(local term-height 16)

(local cmd-cmake :cmake)
(local cmd-build :make)

(var target env.NVIM_CMAKE_TARGET)
(var build-dir :build)
(var build-type :Debug)

(var cur-output-win nil)

(lambda create-dir [dir]
  (mkdir dir :p))

(lambda make-term-string [cwd cmd args]
  (let [escaped-args (map args shellescape)
        cmd-line (.. cmd " " (table.concat escaped-args " "))]
    (.. "term://" cwd "//" cmd-line)))

(lambda after-cmd-cb [?exit-cb {:buf bufnr}]
  (kset :n :q :<Cmd>q<Cr> {:buffer bufnr})
  (when ?exit-cb
    (?exit-cb vim.v.event.status bufnr)))

(lambda open-same-buf [term-string]
  (let [winnr (nvim_get_current_win)
        bufnr (nvim_win_get_buf winnr)]
    (edit term-string)
    (nvim_buf_delete bufnr {})
    winnr))

(lambda run-term [cwd cmd args ?opts]
  (when (and cur-output-win (not (?. ?opts :same-buf)))
    (when (nvim_win_is_valid cur-output-win)
      (nvim_win_close cur-output-win true))
    (set cur-output-win nil))
  (create-dir cwd)
  (let [term-string (make-term-string cwd cmd args)
        same-buf (?. ?opts :same-buf)
        winnr (if same-buf (open-same-buf term-string)
                  (w-hor {:file term-string :focus false :size term-height}))
        bufnr (nvim_win_get_buf winnr)]
    (set cur-output-win winnr)
    (nvim_buf_set_option bufnr :bufhidden :wipe)
    (nvim_create_autocmd :TermClose
                         {:buffer bufnr
                          :callback (partial after-cmd-cb (?. ?opts :on-exit))})))

(lambda add-rerun-map [func _ bufnr]
  (kset :n :r #(func {:same-buf true}) {:buffer bufnr}))

(fn configure [?opts]
  (run-term build-dir cmd-cmake [(.. :-DCMAKE_BUILD_TYPE= build-type) ".."]
            ?opts))

(fn build [?opts]
  (run-term build-dir cmd-build [] ?opts))

(lambda run [{:target t &as opts}]
  (run-term "" (.. build-dir "/" t) [] opts))

(fn run-target [?opts]
  (let [opts (tbl_extend :keep (or ?opts {})
                         {:on-exit (partial add-rerun-map run-target)})]
    (if target
        (run (tbl_extend :force opts {: target}))
        (ui.input {:prompt "Target:" :center true}
                  (fn [input]
                    (when input
                      (set target input)
                      (run (tbl_extend :force opts {:target input}))))))))

(fn build-run-target [?opts]
  (let [on-exit (fn [exit-code]
                  (when (= 0 exit-code)
                    (schedule (partial run-target
                                       {:on-exit (partial add-rerun-map
                                                          build-run-target)
                                        :same-buf (?. ?opts :same-buf)}))))]
    (build (tbl_extend :force (or ?opts {}) {: on-exit}))))

(lambda create-source-header [name]
  (create-dir :include)
  (create-dir :src)
  (let [header-file (.. :include/ name :.hpp)
        source-file (.. :src/ name :.cpp)]
    (w-tab {:file header-file :focus true})
    (w-ver {:file source-file :focus false})))

(fn create-source-header-cb []
  (ui.input {:prompt "Name:" :center true}
            (fn [input]
              (when input
                (create-source-header input)))))

(fn keymaps []
  ;; running
  (kset :n :<Leader>ec configure {:desc :Configure})
  (kset :n :<Leader>eb build {:desc :Build})
  (kset :n :<Leader>er run-target {:desc :Run})
  (kset :n :<Leader>eR build-run-target {:desc "Build & Run"})
  (kset :n :<Leader>cc create-source-header-cb
        {:desc "Create source with header"}))

{: keymaps}
