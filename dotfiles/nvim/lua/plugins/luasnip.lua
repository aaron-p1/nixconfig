local plugin = {}

function plugin.config()
	local ls = require'luasnip'
	local fun = require('fun')
	local helper = require'helper'

	helper.keymap_expr_i_s('<Tab>',
		[[luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>']])
	helper.keymap_lua_i_ns('<S-Tab>', [[require'luasnip'.jump(-1)]])
	helper.keymap_expr_i_s('<C-y>', [['<Plug>luasnip-expand-or-jump']])

	helper.keymap_lua_s_ns('<Tab>', [[require'luasnip'.jump(1)]])
	helper.keymap_lua_s_ns('<S-Tab>', [[require'luasnip'.jump(-1)]])

	helper.keymap_expr_i_s('<C-E>', [[luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>']])
	helper.keymap_expr_s_s('<C-E>', [[luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>']])

	helper.keymap_lua_leader_n_ns('i', [[require'luasnip'.unlink_current()]])

	local types = require("luasnip.util.types")

	ls.config.set_config{
		updateevents = 'TextChanged,TextChangedI',
		region_check_events = 'InsertEnter',
		ext_opts = {
			[types.choiceNode] = {
				active = {
					virt_text = {{"●", "GruvboxOrange"}}
				}
			},
			[types.insertNode] = {
				active = {
					virt_text = {{"●", "GruvboxBlue"}}
				}
			}
		},
	}

	local snippet_groups = fun.iter({
			"all", "c_like", "html", "php", "laravel", "blade"
		})
		:map(function (v)
			return v, require("plugins.my-luasnip." .. v)
		end)
		:tomap()

	local group_assignments = {
		all = {"all"},
		html = {"html"},
		php = {"php", "c_like", "laravel"},
		blade = {"blade", "html"},
	}

	ls.snippets = fun.iter(group_assignments)
		:map(function (ft, groups)
			return ft, fun.iter(groups)
				:map(function (group)
					return snippet_groups[group]
				end)
				:foldl(function (acc, val)
					return fun.chain(acc, val)
				end, {})
				:totable()
		end)
		:tomap()

	-- friendly-snippets
	require'luasnip/loaders/from_vscode'.lazy_load()
end

return plugin
