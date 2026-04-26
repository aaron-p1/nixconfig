local dap = require("dap")

local function get_or_default(value, default)
  if value == nil or value == vim.NIL then
    return default
  end
  return value
end

-- Turn a "run"/"test"/"bench" invocation into one that only compiles,
-- and make cargo print JSON so we can find the produced binary.
local function to_build_args(cargo_args, cargo_extra)
  local out = vim.deepcopy(cargo_args)
  local sub = out[1]

  if sub == "run" then
    out[1] = "build"
  elseif sub == "test" or sub == "bench" then
    table.insert(out, 2, "--no-run")
  end
  table.insert(out, 2, "--message-format=json")

  for _, a in ipairs(get_or_default(cargo_extra, {})) do
    table.insert(out, a)
  end
  return out
end

local function get_kind(cargo_args)
  local sub = cargo_args[1]
  if sub == "run" then
    return "bin"
  elseif sub == "test" then
    return "test"
  end
end

local function get_name(cargo_args)
  for i, arg in ipairs(cargo_args) do
    if arg == "--bin" or arg == "--test" then
      return cargo_args[i + 1]
    end
  end
end

-- Last compiler-artifact with an `executable` field is the one cargo
-- would have run. For `cargo test --no-run` this is the test harness;
-- for `cargo build` it's the bin target.
local function find_executable(stdout, name, kind)
  return vim.iter(vim.split(stdout, "\n", { plain = true }))
      :rev()
      :map(function(line)
        if line ~= "" then
          local ok, msg = pcall(vim.json.decode, line)
          if ok
              and msg.reason == "compiler-artifact"
              and msg.target.name == name
              and vim.list_contains(msg.target.kind, kind) then
            return msg.executable
          end
        end
      end)
      :filter(function(exe) return exe ~= vim.NIL and exe end)
      :next()
end

local function rust_source_map_commands()
  local src     = vim.env.RUST_SRC_PATH
  local info    = vim.fn.system({ "rustc", "-vV" })
  local version = info:match("release:%s*(%S+)")
  local commit  = info:match("commit%-hash:%s*(%S+)")

  local cmds    = {}
  if version then
    table.insert(cmds, string.format(
      'settings append target.source-map "/build/rustc-%s-src/library" "%s"',
      version, src))
  end
  if commit then
    table.insert(cmds, string.format(
      'settings append target.source-map "/rustc/%s/library" "%s"',
      commit, src))
  end
  return cmds
end

local rust_init = nil

local function setup_rust_debug()
  if rust_init == nil then
    local sysroot = vim.fn.trim(vim.fn.system({ "rustc", "--print", "sysroot" }))

    local source_map_cmds = rust_source_map_commands()

    rust_init = {
      'command script import "' .. sysroot .. '/lib/rustlib/etc/lldb_lookup.py"',
      'command source -s 0 "' .. sysroot .. '/lib/rustlib/etc/lldb_commands"',
    }

    vim.list_extend(rust_init, source_map_cmds)
  end
end

local function debug_runnable(runnable)
  vim.notify("Building '" .. runnable.label .. "' with cargo...", vim.log.levels.INFO)

  setup_rust_debug()

  local rargs = runnable.args
  local cargo_cmd = get_or_default(rargs.overrideCargo, "cargo")
  local bargs = to_build_args(rargs.cargoArgs, rargs.cargoExtraArgs)

  local function on_exit(res)
    if res.code ~= 0 then
      vim.notify("Cargo failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
      return
    end

    local kind = get_kind(rargs.cargoArgs)
    local name = get_name(rargs.cargoArgs)
    local exe = find_executable(res.stdout or "", name, kind)
    if not exe or exe == vim.NIL then
      vim.notify("No executable in cargo output", vim.log.levels.ERROR)
      return
    end

    dap.run({
      name         = "Debug Rust: " .. runnable.label,
      type         = "lldb-dap",
      request      = "launch",
      program      = exe,
      args         = get_or_default(rargs.executableArgs, {}),
      cwd          = get_or_default(rargs.workspaceRoot),
      env          = get_or_default(rargs.environment),
      stopOnEntry  = false,
      initCommands = rust_init,
    })
  end

  vim.system(
    vim.list_extend({ cargo_cmd }, bargs),
    { cwd = rargs.workspaceRoot, text = true },
    vim.schedule_wrap(on_exit)
  )
end

dap.adapters["lldb-dap"] = {
  type = "executable",
  command = "lldb-dap",
  name = "lldb-dap",
}

vim.lsp.commands["rust-analyzer.debugSingle"] = function(command)
  local runnable = command.arguments[1]
  debug_runnable(runnable)
end
