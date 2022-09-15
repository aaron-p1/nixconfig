(local {: tbl_map
        : trim
        :api {: nvim_tabpage_list_wins
              : nvim_win_get_buf
              : nvim_buf_get_option
              : nvim_list_tabpages
              : nvim_tabpage_is_valid}
        :fn {: tabpagewinnr}} vim)

(local {: setup} (require :lualine))
(local tab (require :lualine.components.tabs.tab))
(local {: component_format_highlight} (require :lualine.highlight))

(lambda check-opt-in-tab [tabnr option]
  (let [wins (nvim_tabpage_list_wins tabnr)
        bufs (tbl_map #(nvim_win_get_buf $1) wins)]
    (accumulate [result false _ win (ipairs bufs)]
      (or result (nvim_buf_get_option win option)))))

(lambda tab-modify-info [tabnr]
  (let [modified (check-opt-in-tab tabnr :modified)
        modifiable (check-opt-in-tab tabnr :modifiable)]
    (if modified "+"
        (not modifiable) "-"
        "")))

(fn config []
  (setup {:options {:theme :onedark :globalstatus false}
          :extensions [:fugitive :nvim-tree :quickfix]
          :sections {:lualine_a [:mode]
                     :lualine_b [:filename]
                     :lualine_c [:diagnostics]
                     :lualine_x [:diff :branch]
                     :lualine_y [:encoding :filetype]
                     :lualine_z [:progress :location]}
          :inactive_sections {:lualine_a [:filename]
                              :lualine_b [:diagnostics]
                              :lualine_c []
                              :lualine_x [:diff :branch]
                              :lualine_y [:encoding :filetype]
                              :lualine_z [:progress :location]}
          :tabline {:lualine_a [{1 :tabs :max_length (- vim.o.columns 4)}]}})
  (set tab.render
       (fn [self]
         (let [hl (. self.highlights (if self.current :active :inactive))
               name (if self.ellipse "…"
                        (trim (.. self.tabnr " " (self.label self) " "
                                  (tab-modify-info self.tabId))))
               padded-name (tab.apply_padding name self.options.padding)]
           (set self.len (+ (length padded-name) (if self.first 0 1)))
           (.. (if self.first "" (self:separator_before))
               (component_format_highlight hl) padded-name)))))

{: config}
