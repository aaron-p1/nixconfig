local helper = require("plugins.my-luasnip.helper")

local s = helper.s
local t = helper.t
local i = helper.i
local l = helper.l
local fmt = helper.fmt

local fun = require("fun")

local snip_shorts = {
	repeat_tag = function (index) return l(l._1:match("^[^ ]*"), index) end
}

local attributes = {
	i = "id",
	cl = "class",
	h = "href",
	t = "type",
	n = "name",
}

local attribute_snips =
	fun.iter(attributes)
		:map(function (trig, attr)
			return s("a" .. trig, fmt(attr .. '="{}"', {i(1)}))
		end)
		:totable()


local snips = {
	s("<", fmt("<{}>\n\t{}\n</{}>", {
		i(1, "TAG"), i(0), snip_shorts.repeat_tag(1)
	})),
	s("<i", fmt("<{}>{}</{}>", {
		i(1, "TAG"), i(2), snip_shorts.repeat_tag(1)
	})),
	s("=", fmt('="{}"', {i(1)})),
	s("itext", fmt('<input type="text"{}/>', {i(1)})),
	s("inumber", fmt('<input type="number"{}/>', {i(1)})),
}

return fun.chain(snips, attribute_snips):totable()
