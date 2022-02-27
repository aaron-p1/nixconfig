local helper = require("plugins.my-luasnip.helper")

local s = helper.s
local sn = helper.sn
local t = helper.t
local i = helper.i
local c = helper.c

local fmta = helper.fmta

local snips = {
	s("fnga", fmta([[
			public function get<>Attribute(<>)
			{
				return <>;
			}
		]], {
		i(1, "ATTR"),
		c(2, {
			i(1),
			sn(1, {
				i(1),
				t('$value')
			})
		}),
		i(0)
	})),
	s("fnsa", fmta([[
			public function set<>Attribute(<>)
			{
				<>
			}
		]], {
		i(1, "ATTR"),
		i(2, "$value"),
		i(0)
	})),
}

return snips
