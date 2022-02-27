local plugin = {}

function plugin.config()
  vim.g.EditorConfig_exclude_patterns = { "fugitive://.*", "scp://.*" }
end

return plugin
