(local {: trim :keymap {:set kset}} vim)

(local {: read-secret-file :register_plugin_wk register-plugin-wk}
       (require :helper))

(local {: setup} (require :neural))

(local openai-key (trim (read-secret-file :openai-key.txt)))

(fn config []
  (setup {:open_ai {:api_key openai-key}
          :mappings {:swift :<Leader>as :prompt :<Leader>ap}})
  (kset [:n :v] :<Leader>at :<Cmd>NeuralText {:desc :Text})
  (kset [:n :v] :<Leader>ac :<Cmd>NeuralCode {:desc :Code}))

{: config}
