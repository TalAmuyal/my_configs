require('io')
require('os')


function strip(s)
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', '')
	return s
end

function get_query()
	viml = [[
function! Get_query()
    let [line_start, column_start] = getpos(.)[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction
	]]
	return vim.api.nvim_exec(viml, true)
end

function run()
	query = get_query()
	print(query)

	config_path = os.getenv("HOME") .. "/.ssh/dev_db.config"

	db_conf = {}
	for config_line in io.lines(config_path) do
		for k, v in string.gmatch(config_line, "(.+)=(.+)") do
			db_conf[strip(k)] = strip(v)
		end
	end

	--conn = db_conf["DB_TYPE"] .. "://" .. db_conf["USER_NAME"] .. ":" .. db_conf["PASSWORD"] .. "@" .. db_conf["URL"]
	conn = string.format("%s://%s:%s@:%s", db_conf["DB_TYPE"], db_conf["USER_NAME"], db_conf["PASSWORD"], db_conf["URL"])
	query = "SHOW DATABASES"
	command = "DB " .. conn .. " " .. query

	--vim.api.nvim_command(command)
end


test = [[
asdas
11111111
222222
333333
444444
]]


vim.api.nvim_set_keymap("n", "<CR>", ":lua require('talagrip').run()<CR>", { nowait = true, noremap = true, silent = true })

return {
	run = run
}
