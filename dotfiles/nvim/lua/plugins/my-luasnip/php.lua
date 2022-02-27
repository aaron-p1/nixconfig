local helper = require("plugins.my-luasnip.helper")

local s = helper.s
local t = helper.t
local i = helper.i
local c = helper.c

local fmta = helper.fmta

local snips = {
	s("t", t("$this->")),
	s("ufn", t("public function ")),
	s("ofn", t("protected function ")),
	s("ifn", t("private function ")),
	s("fn", fmta("<> function <>(<>)\n{\n\t<>\n}", {
		c(1, {
			t("public"),
			t("projected"),
			t("private"),
		}),
		i(2, "functionname"),
		i(3),
		i(0)
	})),
}

return snips
