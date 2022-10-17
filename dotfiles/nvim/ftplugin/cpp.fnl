(local {:fs {: find} :api {: nvim_echo} :fn {: expand} :keymap {:set kset}} vim)

(local {: contains :open-win {:hor w-hor :ver w-ver :tab w-tab}}
       (require :helper))

(local header-exts [:h :hpp :hh])
(local source-exts [:cpp])

(lambda open-file [open-fn filenames]
  (match (find filenames {})
    [file] (open-fn {: file})
    _ (nvim_echo [["File not found" :ErrorMsg]] false {})))

(lambda add-extensions [name extensions]
  (icollect [_ ext (ipairs extensions)]
    (.. name "." ext)))

(lambda goto-extensions [extensions open-fn]
  (let [cur-f (expand "%:t:r")
        headers (add-extensions cur-f extensions)]
    (open-file open-fn headers)))

(lambda goto-related [open-fn]
  (let [cur-ext (expand "%:e")]
    (if (contains header-exts cur-ext)
        (goto-extensions source-exts open-fn)
        (goto-extensions header-exts open-fn))))

(kset :n :<LocalLeader>eos #(goto-related w-hor) {:buffer 0 :desc :Horizontal})

(kset :n :<LocalLeader>eov #(goto-related w-ver) {:buffer 0 :desc :Vertical})

(kset :n :<LocalLeader>eot #(goto-related w-tab) {:buffer 0 :desc :Tab})
