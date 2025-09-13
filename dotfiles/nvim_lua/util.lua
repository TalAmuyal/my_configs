
local function bind(func, arg)
	return function() func(arg) end
end

local M = {
	bind = bind,

	emptyTable = function(t)
		for k in pairs(t) do
			t [k] = nil
		end
	end,

	has_key = function(t, key)
		for index, _ in ipairs(t) do
			if index == key then
				return true
			end
		end
		return false
	end,

	copy = function(original)
		local copy = {}
		for k, v in pairs(original) do
			copy[k] = v
		end
		return copy
	end,

	is_python_virtual_env = function(python_path)
		local command = string.format('%s -c "import sys; print(hasattr(sys, \'real_prefix\') or (hasattr(sys, \'base_prefix\') and sys.base_prefix != sys.prefix))"', python_path)
		local handle = io.popen(command)
		local result = handle:read('*a')
		handle:close()
		return result:match('True') ~= nil
	end,

	get_shebang = function(cmd)
		-- Get path to the executable
		local exe = vim.fn.exepath(cmd)
		if exe == "" then error("Command not found: " .. cmd) end

		-- read the first line
		local f = io.open(exe, "r")
		if not f then error("Cannot open file: " .. exe) end
		local first_line = f:read("*l")
		f:close()

		if not first_line then error("Empty file: " .. exe) end
		if first_line:sub(1, 2) ~= "#!" then error("No shebang found in " .. exe) end

		return first_line:sub(3):gsub("^%s+", "")
	end,
}

return M
