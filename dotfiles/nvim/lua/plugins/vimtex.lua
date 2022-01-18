local plugin = {}

function plugin.config()
	vim.g.vimtex_compiler_latexmk = {
		executable = '@texlive@/bin/latexmk',
	}
end

return plugin
