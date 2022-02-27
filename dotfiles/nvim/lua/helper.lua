local helper = {}

function helper.registerPluginWk(config)
	assert(config.map ~= nil, 'Map cannot be nil')

	if (package.loaded['which-key']) then
		local wk = require('which-key')

		wk.register(config.map,
			{
				prefix = config.prefix or '',
				buffer = config.buffer
			})
	end
end

function helper.setOptions(optapi, table)
	for key, val in pairs(table) do
		-- check if bool option
		if (tonumber(key) == nil) then
			optapi[key] = val
		else
			local isno = string.sub(val, 0, 2) == 'no'
			local optname = isno
				and string.sub(val, 3, string.len(val))
				or val

			optapi[optname] = not isno
		end
	end
end

return helper
