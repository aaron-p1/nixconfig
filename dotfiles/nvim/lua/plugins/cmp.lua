local plugin = {}

function plugin.config()
	local cmp = require'cmp'
	cmp.setup {
		sources = {
			{ name = 'luasnip' },
			{ name = 'nvim_lsp' },
			{ name = 'cmp_tabnine' },
			{ name = 'path' },
			{ name = 'calc' },
			{ name = 'buffer' },
		},
		snippet = {
			expand = function(args)
				require'luasnip'.lsp_expand(args.body)
			end
		},
		mapping = {
			['<CR>'] = cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Replace,
				select = true
			}),
			['<C-e>'] = cmp.mapping.close(),
			['<C-d>'] = cmp.mapping.scroll_docs(-4),
			['<C-u>'] = cmp.mapping.scroll_docs(4),
		},
		formatting = {
			format = function(entry, vim_item)
				-- set a name for each source
				vim_item.menu = ({
					buffer = '[B]',
					path = '[P]',
					calc = '[C]',
					luasnip = '[SNIP]',
					nvim_lsp = '[LSP]',
					cmp_tabnine = '[T9]',
				})[entry.source.name]
				return vim_item
			end,
		},
	}
end

return plugin
