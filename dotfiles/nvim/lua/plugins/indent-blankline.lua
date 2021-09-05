local plugin = {}

function plugin.config()
	vim.g.indent_blankline_filetype_exclude = {
		'help', 'packer'
	}
	vim.g.indent_blankline_use_treesitter = true
	vim.g.indent_blankline_show_current_context = true
end

return plugin
