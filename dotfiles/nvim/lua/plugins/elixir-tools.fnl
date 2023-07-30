(local {: setup} (require :elixir))
(local {:settings els-settings} (require :elixir.elixirls))

(fn config []
  (setup {:nextls {:enable false}
          :credo {:enable false}
          :elixirls {:cmd :elixir-ls
                     :settings (els-settings {:dialyzerEnabled true
                                              :fetchDeps false
                                              :enableTestLenses true
                                              :suggestSpecs false})}}))

{: config}
