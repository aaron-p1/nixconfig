{ pkgs, ... }: # lua
''
  local dap = require("dap")

  dap.adapters.php = {
    type = "executable",
    port = 9003,
    command = "${pkgs.nodejs_20}/bin/node",
    args = { "${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js" },
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
''
