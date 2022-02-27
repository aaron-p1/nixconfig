local plugin = {}

function plugin.config()
  vim.g.lightline = {
    active = {
      right = {
        { "lineinfo" },
        { "percent" },
        { "spell", "gitbranch", "fileencoding", "filetype" },
      },
    },
    inactive = {
      left = {
        { "mode", "paste" },
        { "readonly", "filename", "modified" },
      },
      right = {
        { "lineinfo" },
        { "percent" },
        { "spell", "gitbranch", "fileencoding", "filetype" },
      },
    },
    tabline = {
      right = {},
    },
    tab = {
      active = { "tabnum", "filename", "tab_modified" },
      inactive = { "tabnum", "filename", "tab_modified" },
    },
    component_function = {
      gitbranch = "FugitiveHead",
    },
    tab_component_function = {
      tab_modified = "LightlineTablineModified",
    },
  }

  function LightlineTablineModified(tabnr)
    local lastwin = vim.fn.tabpagewinnr(tabnr, "$")
    local modified = false
    local modifieable = false

    for i = 1, lastwin, 1 do
      modified = modified or vim.fn.gettabwinvar(tabnr, i, "&modified") == 1
      modifieable = modifieable or vim.fn.gettabwinvar(tabnr, i, "&modifiable") == 1

      if modified and modifieable then
        break
      end
    end

    return modified and "+" or not modifieable and "-" or ""
  end

  vim.cmd([[
	function! LightlineTablineModified(tabnr)
	return luaeval('LightlineTablineModified')(a:tabnr)
	endfunction
	]])
end

return plugin
