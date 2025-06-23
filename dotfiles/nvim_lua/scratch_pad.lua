--[[
A Neovim plugin that provides a scratch buffer in a pop-up window to write ephemeral notes and optionally save them to a predefined location.

**Key Features:**

- Open a floating buffer for writing notes
- Configurable file location
- Clear the file (using C-l)
- Save and close the buffer with a key binding (default: <C-s>)
- Close the buffer without saving with a key binding (default: <C-c>)
]]

local actions      = require("telescope.actions")
local action_state = require("telescope.actions.state")
local util         = require("util")

local state = {
	buffer = nil,
}

local default_config = {
	width = 0.6,
	height = 0.6,
	file_path = vim.fn.expand("~/.local/share/nvim/tala-scratchpad/notes.md"),
}

local config = {}

local nilable_configs = {
	file_path = true,
}

local function get_config(name)
	if nilable_configs[name] and util.has_key(config, name) then
		return config[name]
	end

	return config[name] or default_config[name]
end

local function setup(opts)
	config = vim.tbl_extend("force", config, opts or {})
end

local function open()
	if state.buffer == nil or not vim.api.nvim_buf_is_valid(state.buffer) then
		local file_path = get_config("file_path")
		state.buffer = vim.api.nvim_create_buf(false, file_path == nil)
		if file_path ~= nill then
			vim.api.nvim_buf_set_name(state.buffer, get_config("file_path"))
		end

		vim.api.nvim_buf_set_option(state.buffer, "filetype", "markdown")
		vim.api.nvim_buf_set_option(state.buffer, "modifiable", true)
		vim.api.nvim_buf_set_option(state.buffer, "swapfile", false)

		vim.api.nvim_buf_set_keymap(state.buffer, "n", "<C-s>", [[:w<CR>]], { noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(state.buffer, "n", "<C-c>", [[:q!<CR>]], { noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(state.buffer, "n", "<C-l>", [[:%d<CR>]], { noremap = true, silent = true })
	end

	local width = math.floor(vim.o.columns * get_config("width"))
	local height = math.floor(vim.o.lines * get_config("height"))
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	vim.api.nvim_open_win(state.buffer, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})
end

return {
	setup = setup,
	open = open,
}
