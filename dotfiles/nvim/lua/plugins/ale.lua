local plugin = {}

function plugin.config()
	vim.g.ale_linters = {
		php = {'psalm', 'phpmd', 'php'}
	}

	vim.g.ale_fixers = {
		php = {'php_cs_fixer'},
		javascript = {'standard'},
		json = {'jq'},
		dart = {'dartfmt'}
	}
	vim.g.ale_virtualtext_cursor = 1
	vim.g.ale_sign_priority = 1
end

return plugin
