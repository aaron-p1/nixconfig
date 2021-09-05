local plugin = {}

function plugin.config()
	vim.g.gruvbox_italic = 1
	vim.cmd [[colorscheme gruvbox]]
end

return plugin
