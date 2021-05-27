local M = {
	emptyTable = function(t)
		for k in pairs(t) do
			t [k] = nil
		end
	end,

	get_python_virt_env = function()
		return string.match(
			vim.loop.cwd(),
			"dev/(analytics_%d)"
		)
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
