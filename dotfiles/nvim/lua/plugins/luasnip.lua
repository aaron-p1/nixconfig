local plugin = {}

local function showIfUsed(args, text)
	local result = args[1][1] == '' and '' or text
	print(vim.inspect(args[3]))
	return result
end


function plugin.config()
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

	local ls = require'luasnip'

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

	local parse = ls.parser.parse_snippet
	local s = ls.snippet
	local sn = ls.snippet_node
	local t = ls.text_node
	local i = ls.insert_node
	local f = ls.function_node
	local c = ls.choice_node
	local d = ls.dynamic_node

	-- Make sure to not pass an invalid command, as io.popen() may write over nvim-text.
	local function shell(_, _, command)
		local file = io.popen(command, "r")
		local res = {}
		for line in file:lines() do
			table.insert(res, line)
		end
		return res
	end


	ls.snippets = {
		all = {
			s('uuidgen', f(shell, {}, 'uuidgen')),
			s('date', f(shell, {}, 'date --iso-8601')),
			s('datetime', f(shell, {}, 'date --rfc-3339=seconds')),
			s('datetimei', f(shell, {}, 'date --iso-8601=seconds')),
			-- parse(
			-- 	'test', 'Just testing: ${1:Stuff}'
			-- )
		},
		php = {
			-- [private] function $2() [use ($3)] $4{
			--     $0
			-- }
			parse('of', 'protected function $0'),
			parse('uf', 'public function $0'),
			parse('if', 'private function $0'),
			s('func', {
					c(1, {
							t('public'),
							t('private'),
							t('protected'),
						}),
					t(' function '), i(2), t('('), i(3), t(') '),
					t({'', '{', '\t'}),
					i(0),
					t({'', '}'})
				})
		}
	}

	-- friendly-snippets
	require'luasnip/loaders/from_vscode'.lazy_load()
end

return plugin
