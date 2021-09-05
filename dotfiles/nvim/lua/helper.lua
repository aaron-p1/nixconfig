local helper = {}

function helper.tableConcat(t1, t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

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

-- KEYMAPS

local function keymap_cmd_ns(mode, key, cmd)
	vim.api.nvim_set_keymap(mode, key, '<Cmd>'..cmd..'<CR>', {
		noremap = true,
		silent = true,
	})
end

local function keymap_cmd_leader_ns(mode, key, cmd)
	keymap_cmd_ns('n', '<leader>'..key, cmd)
end

local function keymap_lua_ns(mode, key, lua)
	keymap_cmd_ns(mode, key, 'lua '..lua)
end

local function keymap_lua_leader_ns(mode, key, lua)
	keymap_cmd_leader_ns(mode, key, 'lua '..lua)
end

local function keymap_b_cmd_ns(mode, buf, key, cmd)
	vim.api.nvim_buf_set_keymap(buf, mode, key, '<Cmd>'..cmd..'<CR>', {
		noremap = true,
		silent = true,
	})
end

local function keymap_b_cmd_leader_ns(mode, buf, key, cmd)
	keymap_b_cmd_ns('n', buf, '<leader>'..key, cmd)
end

local function keymap_expr_s(mode, key, expr)
	vim.api.nvim_set_keymap(mode, key, expr, {
		silent = true,
		expr = true
	})
end

local function keymap_b_lua_ns(mode, buf, key, lua)
	keymap_b_cmd_ns(mode, buf, key, 'lua '..lua)
end

local function keymap_b_lua_leader_ns(mode, buf, key, lua)
	keymap_b_cmd_leader_ns(mode, buf, key, 'lua '..lua)
end

function helper.keymap_cmd_n_ns(...)
	keymap_cmd_ns('n', ...)
end

function helper.keymap_cmd_s_ns(...)
	keymap_cmd_ns('s', ...)
end

function helper.keymap_cmd_leader_n_ns(...)
	keymap_cmd_leader_ns('n', ...)
end

function helper.keymap_cmd_leader_v_ns(...)
	keymap_cmd_leader_ns('v', ...)
end

function helper.keymap_b_cmd_leader_n_ns(...)
	keymap_b_cmd_leader_ns('n', ...)
end

function helper.keymap_b_cmd_n_ns(...)
	keymap_b_cmd_ns('n', ...)
end

function helper.keymap_lua_n_ns(...)
	keymap_lua_ns('n', ...)
end

function helper.keymap_lua_i_ns(...)
	keymap_lua_ns('i', ...)
end

function helper.keymap_lua_s_ns(...)
	keymap_lua_ns('s', ...)
end

function helper.keymap_lua_leader_n_ns(...)
	keymap_lua_leader_ns('n', ...)
end

function helper.keymap_b_lua_n_ns(...)
	keymap_b_lua_ns('n', ...)
end

function helper.keymap_b_lua_leader_n_ns(...)
	keymap_b_lua_leader_ns('n', ...)
end

function helper.keymap_expr_i_s(...)
	keymap_expr_s('i', ...)
end

function helper.keymap_expr_s_s(...)
	keymap_expr_s('s', ...)
end

-- KEYMAPS END

return helper
