(local {: nvim_list_bufs} vim.api)

(local {:setup {:cmdline s-cmdline :filetype s-filetype &as setup}
        :mapping {: complete
                  : confirm
                  : abort
                  : close
                  : scroll_docs
                  : select_next_item
                  : select_prev_item
                  &as cm}
        :ConfirmBehavior {:Replace con-replace}
        :SelectBehavior {:Insert sel-insert}
        :config {: c-disable : sources}
        :PreselectMode {:Item pre-item}} (require :cmp))

(local cc (require :cmp.config.compare))
(local {: cmp_format} (require :lspkind))

(local cmp-sources
       [{:name :nmp}
        {:name :orgmode}
        {:name :nvim_lsp :max_item_count 64}
        {:name :luasnip}
        {:name :path :options {:fd_timeout_msec 1000 :fd_cmd [:fd :-d :4 :-p]}}
        {:name :calc}
        {:name :digraphs :max_item_count 32}
        {:name :buffer :option {:get_bufnrs #(nvim_list_bufs)}}])

(fn config []
  (setup {:sources cmp-sources
          :sorting {:priority_weight 2
                    :comparators [cc.offset
                                  cc.exact
                                  cc.score
                                  cc.recently_used
                                  cc.kind
                                  cc.sort_text
                                  cc.length
                                  cc.order]}
          :snippet {:expand #(let [ls (require :luasnip)]
                               (ls.lsp_expand $1.body))}
          :mapping {:<C-Space> (complete)
                    :<C-y> (confirm {:behavior con-replace :select true})
                    :<C-e> (cm {:i (abort) :c (close)})
                    :<M-e> (close)
                    :<C-u> (scroll_docs -4)
                    :<C-d> (scroll_docs 4)
                    :<C-n> (cm (select_next_item {:behavior sel-insert})
                               [:i :c])
                    :<C-p> (cm (select_prev_item {:behavior sel-insert})
                               [:i :c])
                    :<Tab> (cm (select_next_item {:behavior sel-insert}) [:c])
                    :<Up> c-disable
                    :<Right> c-disable
                    :<Down> c-disable
                    :<Left> c-disable}
          :preselect pre-item
          :formatting {:format (cmp_format {:mode :symbol_text
                                            :menu {:npm "[NPM]"
                                                   :nvim_lsp "[LSP]"
                                                   :luasnip "[SNIP]"
                                                   :path "[P]"
                                                   :calc "[C]"
                                                   :digraphs "[DG]"
                                                   :buffer "[B]"
                                                   :omni "[OMNI]"
                                                   :copilot "[COP]"}})}
          :experimental {:ghost_text true}})
  (s-cmdline "/" {:sources [{:name :buffer}]})
  (s-cmdline ":"
             {:sources (sources [{:name :path}]
                                [{:name :cmdline}
                                 {:name :cmdline_history :max_item_count 4}])}))

{: config}
