{ pkgs, ... }: {
  name = "dap";
  plugins = with pkgs.vimPlugins; [
    nvim-dap
    nvim-dap-virtual-text
    nvim-dap-ui
  ];
  config = # lua
    ''
      local dap = require("dap")
      local du = require("dapui")

      vim.keymap.set("n", "<F1>", dap.repl.toggle, { desc = "Toggle dap repl" })
      vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Step over" })
      vim.keymap.set("n", "<F3>", dap.step_into, { desc = "Step into" })
      vim.keymap.set("n", "<F4>", dap.step_out, { desc = "Step out" })

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Continue" })
      vim.keymap.set("n", "<F6>", dap.disconnect, { desc = "Disconnect" })
      vim.keymap.set("n", "<F7>", dap.run_to_cursor, { desc = "Run to cursor" })
      vim.keymap.set("n", "<F8>", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<Leader><F8>", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Set breakpoint with condition" })
      vim.keymap.set("n", "<F9>", dap.list_breakpoints, { desc = "List breakpoints" })
      vim.keymap.set("n", "<F10>", dap.up, { desc = "Stack up" })
      vim.keymap.set("n", "<Leader><F10>", dap.down, { desc = "Stack down" })

      vim.keymap.set("n", "<Leader>dd", du.toggle, { desc = "Toggle dap UI" })
      vim.keymap.set({ "n", "v" }, "<Leader>de", du.eval, { desc = "Evaluate expression" })

      du.setup({
        controls = { enabled = false },
        element_mappings = {},
        expand_lines = true,
        floating = {
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        force_buffers = true,
        icons = {
          collapsed = "",
          current_frame = "",
          expanded = "",
        },
        layouts = {
          {
            elements = {
              {
                id = "scopes",
                size = 0.45,
              },
              {
                id = "watches",
                size = 0.25,
              },
              {
                id = "breakpoints",
                size = 0.10,
              },
              {
                id = "stacks",
                size = 0.20,
              },
            },
            position = "left",
            size = 60,
          },
          {
            elements = {
              {
                id = "repl",
                size = 0.5,
              },
              {
                id = "console",
                size = 0.5,
              },
            },
            position = "bottom",
            size = 20,
          },
        },
        mappings = {
          edit = "e",
          expand = { "<CR>" },
          open = "o",
          remove = "d",
          repl = "r",
          toggle = "t",
        },
        render = {
          indent = 1,
          max_value_lines = 100,
        },
      })

      require("nvim-dap-virtual-text").setup()

      dap.adapters.php = {
        type = "executable",
        port = 9003,
        command = "${pkgs.nodejs_16}/bin/node",
        args = { "${pkgs.local.vscode-php-debug}/out/phpDebug.js" },
      }

      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug",
          serverSourceRoot = "/var/www",
          localSourceRoot = vim.fn.getcwd(),
        },
      }

      Configs.which_key.register({
        prefix = "<Leader>",
        map = { d = { name = "dap" } }
      })
    '';
}
