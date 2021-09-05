local plugin = {}

function plugin.config()
	local tabnine = require('cmp_tabnine.config')
	tabnine:setup({
		max_lines = 1000;
		max_num_results = 5;
		sort = true;
	})
end

return plugin
