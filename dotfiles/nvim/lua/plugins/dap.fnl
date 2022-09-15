(local {:fn {: input : getcwd} :keymap {:set kset}} vim)

(local {:repl {:toggle toggle-repl}
        : step_over
        : step_into
        : step_out
        : continue
        : disconnect
        : run_to_cursor
        : toggle_breakpoint
        : list_breakpoints
        : up
        : down
        : adapters
        : configurations} (require :dap))

;; https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

(fn config []
  (kset :n :<F1> toggle-repl)
  (kset :n :<F2> step_over)
  (kset :n :<F3> step_into)
  (kset :n :<F4> step_out)
  ;; continue or run
  (kset :n :<F5> continue)
  (kset :n :<F6> disconnect)
  (kset :n :<F7> run_to_cursor)
  (kset :n :<F8> toggle_breakpoint)
  (kset :n :<Leader><F8> #(toggle_breakpoint (input "Breakpoint condition: "))
        {:desc "Conditional Breakpoint"})
  (kset :n :<F9> list_breakpoints)
  (kset :n :<F10> up)
  (kset :n :<Leader><F10> down {:desc "Stack Down"})
  (set adapters.php
       {:type :executable
        ; DEPENDENCIES: nodejs
        :command :node
        :args ["@phpdebug@/libexec/php-debug/deps/php-debug/out/phpDebug.js"]})
  (set configurations.php
       [{:type :php
         :request :launch
         :name "Listen for Xdebug"
         :port 9000
         :serverSourceRoot :/var/www/html/
         :localSourceRoot (.. (getcwd) "/")}]))
