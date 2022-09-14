(local {: nvim_list_bufs} vim.api)

(local {:mapping cm :config co &as cmp} (require :cmp))

(local cc (require :cmp.config.compare))
(local lspkind (require :lspkind))

(fn config []
  (cmp.setup {:sources [{:name :nmp}
                        {:name :nvim_lsp :max_item_count 32}
                        {:name :luasnip}
                        {:name :path
                         :options {:fd_timeout_msec 1000
                                   :fd_cmd [:fd :-d :4 :-p]}}
                        {:name :calc}
                        {:name :digraphs :max_item_count 4}
                        {:name :buffer
                         :option {:get_bufnrs #(nvim_list_bufs)}}]
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
              :mapping {:<C-Space> (cm.complete)
                        :<C-y> (cm.confirm {:behavior cmp.ConfirmBehavior.Replace
                                            :select true})
                        :<C-e> (cm {:i (cm.abort) :c (cm.close)})
                        :<M-e> (cm.close)
                        :<C-u> (cm.scroll_docs -4)
                        :<C-d> (cm.scroll_docs 4)
                        :<C-n> (cm (cm.select_next_item {:behavior cmp.SelectBehavior.Insert})
                                   [:i :c])
                        :<C-p> (cm (cm.select_prev_item {:behavior cmp.SelectBehavior.Insert})
                                   [:i :c])
                        :<Tab> (cm (cm.select_next_item {:behavior cmp.SelectBehavior.Insert})
                                   [:c])
                        :<Up> co.disable
                        :<Right> co.disable
                        :<Down> co.disable
                        :<Left> co.disable}
              :preselect cmp.PreselectMode.Item
              :formatting {:format (lspkind.cmp_format {:mode :symbol_text
                                                        :menu {:npm "[NPM]"
                                                               :nvim_lsp "[LSP]"
                                                               :luasnip "[SNIP]"
                                                               :path "[P]"
                                                               :calc "[C]"
                                                               :cmp_tabnine "[T9]"
                                                               :digraphs "[DG]"
                                                               :buffer "[B]"
                                                               :omni "[OMNI]"
                                                               :copilot "[COP]"}})}
              :experimental {:ghost_text true}})
  (cmp.setup.cmdline "/" {:sources [{:name :buffer}]})
  (cmp.setup.cmdline ":"
                     {:sources (co.sources [{:name :path}]
                                           [{:name :cmdline}
                                            {:name :cmdline_history
                                             :max_item_count 4}])}))

{: config}
