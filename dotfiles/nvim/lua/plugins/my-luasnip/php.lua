local fun = require("fun")
local helper = require("helper")

local lsh = require("plugins.my-luasnip.helper")

local s = lsh.s
local sn = lsh.sn
local t = lsh.t
local i = lsh.i
local c = lsh.c
local d = lsh.d

local fmta = lsh.fmta

local firstLine = lsh.firstLine
local firstInFile = lsh.firstInFile

local function getNamespaceFromPath()
  local path = vim.fn.expand("%:h")

  if path == "." then
    return nil
  end

  return fun.iter(vim.fn.split(path, "/"))
    :map(function(dir)
      return dir:gsub("^%l", string.upper)
    end)
    :foldl(function(acc, v)
      if acc == nil then
        return v
      end
      return acc .. "\\" .. v
    end, nil)
end

local function getNamespaceFromFile()
  local path = vim.fn.expand("%:h")
  local filename = vim.fn.expand("%:t")

  local file_to_read = fun.iter(vim.fn.readdir(path))
    :filter(function(file)
      return helper.endsWith(file, ".php") and file ~= filename
    end)
    :nth(1)

  if file_to_read == nil then
    return nil
  end

  for _, line in pairs(vim.fn.readfile(path .. "/" .. file_to_read, "", 5)) do
    if helper.startsWith(line, "namespace") then
      return line:match("%w+ (.+);")
    end
  end

  return nil
end

local function getNamespaceLine(namespace)
  return sn(nil, { t({ "", "namespace " }), i(1, namespace), t({ ";", "" }) })
end

local function getNamespace()
  local result = getNamespaceFromFile()

  if result ~= nil then
    return getNamespaceLine(result)
  end

  result = getNamespaceFromPath()

  if result == nil then
    return ""
  end
  return getNamespaceLine(result)
end

local function getClassName()
  return sn(nil, i(1, vim.fn.expand("%:t:r")))
end

local snips = {
  s(
    "init",
    fmta("<<?php\n<>\nclass <><>\n{\n\t<>\n}", {
      d(1, getNamespace, {}),
      d(2, getClassName, {}),
      i(3),
      i(0),
    }),
    { condition = firstInFile, show_condition = firstLine }
  ),
  s("th", t("$this->")),
  s("ufn", t("public function ")),
  s("ofn", t("protected function ")),
  s("ifn", t("private function ")),
  s(
    "fn",
    fmta("<> function <>(<>)\n{\n\t<>\n}", {
      c(1, {
        t("public"),
        t("projected"),
        t("private"),
      }),
      i(2, "functionname"),
      i(3),
      i(0),
    })
  ),
}

return snips
