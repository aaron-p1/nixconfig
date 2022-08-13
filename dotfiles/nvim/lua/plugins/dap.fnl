(local {:set kset} vim.keymap)

;; https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

(fn config []
  (local dap (require :dap))
  (kset :n :<F1> dap.repl.toggle)
  (kset :n :<F2> dap.step_over)
  (kset :n :<F3> dap.step_into)
  (kset :n :<F4> dap.step_out)
  ;; continue or run
  (kset :n :<F5> dap.continue)
  (kset :n :<F6> dap.disconnect)
  (kset :n :<F7> dap.run_to_cursor)
  (kset :n :<F8> dap.toggle_breakpoint)
  (kset :n :<Leader><F8>
        #(dap.toggle_breakpoint (vim.fn.input "Breakpoint condition: "))
        {:desc "Conditional Breakpoint"})
  (kset :n :<F9> dap.list_breakpoints)
  (kset :n :<F10> dap.up)
  (kset :n :<Leader><F10> dap.down {:desc "Stack Down"})
  (set dap.adapters.php
       {:type :executable
        ; DEPENDENCIES: nodejs
        :command :node
        :args ["@phpdebug@/libexec/php-debug/deps/php-debug/out/phpDebug.js"]})
  (set dap.configurations.php
       [{:type :php
         :request :launch
         :name "Listen for Xdebug"
         :port 9000
         :serverSourceRoot :/var/www/html/
         :localSourceRoot (.. (vim.fn.getcwd) "/")}]))
