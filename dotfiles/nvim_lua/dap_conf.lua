local util = require("util")

local home_directory = vim.fn.expand("~")
local python_path = home_directory .. "/.local/python_venvs/debugpy/bin/python"
if not vim.fn.executable(python_path) then return end


local dap = require("dap")

local dap_ui = require("dapui")
dap_ui.setup()

require("nvim-dap-virtual-text").setup {
	enabled = true,                        -- enable this plugin (the default)
	enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
	highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
	highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
	show_stop_reason = true,               -- show stop reason when stopped for exceptions
	commented = true,                      -- prefix virtual text with comment string
	only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
	all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
	filter_references_pattern = '<module', -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
	-- experimental features:
	virt_text_pos = 'eol',                 -- position of virtual text, see `:h nvim_buf_set_extmark()`
	all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
	virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
	virt_text_win_col = nil                -- position the virtual text at a fixed window column (starting from the first text column) ,
	                                       -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
}

local dap_python = require("dap-python")
dap_python.setup(python_path)
dap_python.test_runner = "pytest"

local run_config = {
	type = "python",
	request = "launch",
	name = "The true launch configuration",
	program = "${file}",
}

local state = {
	is_running = false,
}

local M = {
	toggle_on_off = function()
		dap_ui.toggle()
		if state.is_running then dap.close() else dap_python.test_method() end
		--if state.is_running then dap.close() else dap.run(run_config) end
		state.is_running = not state.is_running
	end,

	run_test_method   = function() dap_python.test_method() end,
	toggle_breakpoint = function() dap.toggle_breakpoint()  end,

	step_over     = function() dap.step_over    () end,
	step_into     = function() dap.step_into    () end,
	step_out      = function() dap.step_out     () end,
	run_to_cursor = function() dap.run_to_cursor() end,

	continue = function() dap.continue() end,
}

return M
