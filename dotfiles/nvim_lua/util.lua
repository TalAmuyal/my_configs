local M = {
	emptyTable = function(t)
		for k in pairs(t) do
			t [k] = nil
		end
	end,

	is_python_virtual_env = function(python_path)
		local command = string.format('%s -c "import sys; print(hasattr(sys, \'real_prefix\') or (hasattr(sys, \'base_prefix\') and sys.base_prefix != sys.prefix))"', python_path)
		local handle = io.popen(command)
		local result = handle:read('*a')
		handle:close()
		return result:match('True') ~= nil
	end,

	bind_lua_cmd = function(keys, cmd)
		vim.api.nvim_set_keymap(
			"n",
			keys,
			"<cmd>lua " .. cmd .. "<CR>",
			{ noremap = true, silent = true }
		)
	end,
}

return M
