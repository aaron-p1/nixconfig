(local {: nvim_echo : validate :fn {: stdpath : readdir}} vim)

(local {: ripairs : map : any} (require :helper))

(local {: sync :wait await} (require :packer.async))
(local jobs (require :packer.jobs))

(local datadir (stdpath :data))
(local configdir (stdpath :config))

(fn check-return-code [patch r]
  (when (not= 0 r.exit_code)
    (print (.. "Error applying patch: " patch))))

(lambda apply-patch-list [patch-list dir ?reverse]
  (let [iter (if ?reverse ripairs ipairs)]
    (each [_ patch (iter patch-list)]
      (await (jobs.run [:patch
                        :--quiet
                        (if ?reverse :--reverse :--forward)
                        :--strip=1
                        (.. :--input= patch)]
                       {:cwd dir
                        :success_test (partial check-return-code patch)})))))

(lambda get-applied-patches-dir [plugin-name]
  (.. datadir :/site/pack/packer/plugin-patches/ plugin-name))

(lambda reverse-plugin-patches [plugin-name dir]
  (let [applied-patches-dir (get-applied-patches-dir plugin-name)
        applied-patches (icollect [_ file (ipairs (readdir applied-patches-dir))]
                          (.. applied-patches-dir "/" file))]
    (apply-patch-list applied-patches dir true)
    (each [_ patch (ipairs applied-patches)]
      (os.remove patch))))

(lambda apply-plugin-patches [plugin-name dir patch-list]
  (let [patch-dir (.. configdir :/plugin-patches/ plugin-name)
        fullpath-list (map patch-list #(.. patch-dir "/" $1))
        applied-patches-dir (get-applied-patches-dir plugin-name)]
    (apply-patch-list fullpath-list dir)
    (os.execute (.. "mkdir -p -- '" applied-patches-dir "'"))
    (when (not= 0 (length fullpath-list))
      (let [path-string (table.concat (map fullpath-list #(.. "'" $1 "'")) " ")
            cp-cmd (.. "cp --no-preserve=all -- " path-string " '"
                       applied-patches-dir "'")]
        (os.execute cp-cmd)))))

(lambda patch-after [func plugin-name install-path patch-list]
  (let [prev-result (await (func))]
    (apply-plugin-patches plugin-name install-path patch-list)
    prev-result))

(fn handle-patches [plugins plugin value]
  (validate {:value [value [:string :table]]})
  (let [plugin-name plugin.short_name
        install-path plugin.install_path
        prev-installer plugin.installer
        prev-updater plugin.updater
        patch-list (if (= (type value) :string) [value] value)
        new-installer (fn [disp opts]
                        (sync (fn []
                                (patch-after (partial prev-installer disp opts)
                                             plugin-name install-path patch-list))))
        new-updater (fn [disp opts]
                      (sync (fn []
                              (reverse-plugin-patches plugin-name install-path)
                              (patch-after (partial prev-updater disp opts)
                                           plugin-name install-path patch-list))))]
    (when (any patch-list #(string.match $1 "/"))
      (error "Patch should not contain /"))
    (set plugin.updater new-updater)))

{: handle-patches}
