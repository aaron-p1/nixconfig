local plugin = {}

function plugin.config()
	require('nvim-treesitter.configs').setup {
		highlight = {
			enable = true, -- false will disable the whole extension
		},
		incremental_selection = {
			enable = true,
			-- don't know if used
			keymaps = {
				init_selection = 'gnn',
				node_incremental = 'grn',
				scope_incremental = 'grc',
				node_decremental = 'grm',
			}
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
