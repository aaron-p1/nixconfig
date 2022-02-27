local plugin = {}

function plugin.config()
	require('nvim-treesitter.configs').setup {
		highlight = {
			enable = true, -- false will disable the whole extension
		},
		indent = {
			enable = true,
		},
		autotag = {
			enable = true,
			filetypes = {
				'html',
				'xml',
				'blade',
				'vue'
			}
		}
	}
end

return plugin
