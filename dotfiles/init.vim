let g:python3_host_prog = '~/.local/python_venvs/pynvim/bin/python'

" Install the `plug` plugin-manager if it is missing
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

let s:work_instance = getcwd() . '/' =~ '^' . $HOME . '/dev/'
let s:non_work_instance = !s:work_instance

" Collect plugins
call plug#begin('~/.vim/plugged')
Plug 'github/copilot.vim'
Plug 'CopilotC-Nvim/CopilotChat.nvim'
Plug 'nvim-lua/plenary.nvim'  " LUA utils, required by telescope
Plug 'sharkdp/fd'  " "find" replacment, required by telescope
Plug 'nvim-telescope/telescope.nvim'
Plug 'voldikss/vim-floaterm'
Plug 'iCyMind/NeoSolarized'
Plug 'wellle/targets.vim'
Plug 'nelstrom/vim-visual-star-search'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-dadbod'
Plug 'sheerun/vim-polyglot'
Plug 'cespare/vim-toml'  " Support for highlighting toml filetype
Plug 'knsh14/vim-github-link'
"
"LSP
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/vim-vsnip'
Plug 'tami5/lspsaga.nvim'
"
"DAP
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-neotest/nvim-nio'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'mfussenegger/nvim-dap-python'
"
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " After installation, run :TSInstall python
Plug 'wsdjeg/vim-fetch'
Plug 'rmagatti/auto-session'
call plug#end()

" Set syntax of specific file name to specific file type
autocmd BufNewFile,BufRead Pipfile      setf toml
autocmd BufNewFile,BufRead Pipfile.lock setf json

autocmd BufReadCmd *.egg,*.whl,*.jar,*.xpi call zip#Browse(expand("<amatch>"))

" Set Groovy indentation
autocmd FileType groovy setlocal shiftwidth=4 softtabstop=4 expandtab


autocmd TextYankPost * silent! lua vim.highlight.on_yank({timeout=200})

let g:black_linelength = s:work_instance ? 120 : 79
let g:black_virtualenv = "~/.local/python_venvs/black"
let g:black_target_version = "py310"
"autocmd BufWritePre *.py execute ':Black'


set shell=zsh

lua <<EOF
-- Add my dotfiles repo to the runtime path
local my_vim_rc = os.getenv("MYVIMRC")
real_my_vim_rc = vim.fn.resolve(vim.fn.expand(my_vim_rc))
my_lua_modules_dir = real_my_vim_rc:gsub("init.vim$", "") .. "nvim_lua"
package.path = package.path .. ";" .. my_lua_modules_dir .. "/?.lua"

local util = require("util")
local dap_conf = require('dap_conf')


local function set_for_filetype(filetype, callback)
	local group_name = filetype .. "Group"
	local group = vim.api.nvim_create_augroup(group_name, { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		pattern = filetype,
		callback = callback,
		group = group,
	})
end


-- Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


-- General nvim configs

vim.opt.number = true
vim.opt.relativenumber = true
local function set_line_numbers()
    vim.opt_local.number = true
    vim.opt_local.relativenumber = true
end

vim.o.completeopt = "menu,menuone,noselect,noinsert,popup" -- Better completion experience

vim.api.nvim_create_autocmd("TermOpen", {
  callback = set_line_numbers,
  group = vim.api.nvim_create_augroup("TerminalLineNumbers", { clear = true }),
})


-- Setup nvim-cmp
local cmp = require("cmp")

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users
    end,
  },
  mapping = {
  ["<Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item()
    else
      fallback() -- The fallback function sends an already mapped key. In this case, it's probably <Tab>
    end
  end, { "i", "s" }),

  ["<S-Tab>"] = cmp.mapping(function()
    if cmp.visible() then
      cmp.select_prev_item()
    elseif vim.fn["vsnip#jumpable"](-1) == 1 then
      feedkey("<Plug>(vsnip-jump-prev)", "")
    end
  end, { "i", "s" }),

    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'spell' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup lspconfig
local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

lspconfig["pylsp"].setup {
  capabilities = capabilities,
  settings = {
    pylsp = {
      plugins = {
        jedi = {
          environment = vim.fn.getcwd() .. "/.venv"
        }
      }
    }
  },
}

lspconfig.rust_analyzer.setup({})

require("CopilotChat").setup({
  window = {
    layout = "float",
    width = 0.8,
    height = 0.8,
  }
})
set_for_filetype("copilot-chat", function()
    vim.defer_fn(set_line_numbers, 10) -- Needed to override Telescope's line numbers setting
end)


require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "c",
    "diff",
    "dockerfile",
    "groovy",
    "java",
    "json",
    "kotlin",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "rust",
    "sql",
    "toml",
    "vim",
    "vimdoc",
    "yaml",
  },
})


local function set_leader_keymap(keys, command, description)
    vim.keymap.set(
        "n",
        "<leader>" .. keys,
        command,
        { silent = true, desc = "## " .. description }
    )
end

local function cmd_func(cmd)
  return util.bind(vim.cmd, cmd)
end

local my_notes_dir = "~/.local/work_configs/notes"
local get_buffer_dir = util.bind(vim.fn.expand, "%:h")

local function saga_cmd(cmd) return cmd_func("Lspsaga " .. cmd) end

local telescope_cmds = require("telescope.builtin")

local function tele_find(search, location)
	return function()
		telescope_cmds[search]({
			cwd = (type(location) == "string" and location) or location(),
		})
	end
end

local function prep_to_edit_current_dir()
	vim.api.nvim_feedkeys(":edit " .. vim.fn.expand("%:h") .. "/", "n", false)
end

local toggle_floaterm = cmd_func("FloatermToggle")

local function set_normal_and_terminal_keymap(key, command)
	for _, mode in ipairs({ "n", "t" }) do
		complete_command = mode == "n" and command or ("<C-\\><C-N>" .. command)
		vim.keymap.set(mode, key, complete_command)
	end
end

-- Quicker window & tab movement
for _, key in ipairs({ "j", "k", "h", "l" }) do
	set_normal_and_terminal_keymap("<C-" .. key .. ">", "<C-w>" .. key)
end
set_normal_and_terminal_keymap("<C-S-H>", "gT")
set_normal_and_terminal_keymap("<C-S-L>", "gt")


set_leader_keymap("km", cmd_func("Telescope keymaps"),           "Show keymaps")
set_leader_keymap("F",  vim.lsp.buf.format,                      "LSP: Format buffer")
set_leader_keymap("gd", vim.lsp.buf.definition,                  "LSP: Go to definition")
set_leader_keymap("gD", vim.lsp.buf.declaration,                 "LSP: Go to declaration")
set_leader_keymap("sp", saga_cmd("preview_definition"),          "LSP: Preview definition")
set_leader_keymap("gr", vim.lsp.buf.references,                  "LSP: Go to references")
set_leader_keymap("gi", vim.lsp.buf.implementation,              "LSP: Go to implementation")
set_leader_keymap("ca", saga_cmd("code_action"),                 "LSP: Code action")
set_leader_keymap("rr", saga_cmd("rename"),                      "LSP: Rename")
set_leader_keymap("sd", saga_cmd("hover_doc"),                   "LSP: Show documentation")
set_leader_keymap("sh", saga_cmd("signature_help"),              "LSP: Show signature help")
set_leader_keymap("jn", saga_cmd("diagnostic_jump_next"),        "LSP: Jump to next diagnostic")
set_leader_keymap("dt", dap_conf.toggle_on_off,                  "DAP: Toggle on/off")
set_leader_keymap("db", dap_conf.toggle_breakpoint,              "DAP: Toggle breakpoint")
set_leader_keymap("du", dap_conf.step_over,                      "DAP: Step over")
set_leader_keymap("di", dap_conf.step_into,                      "DAP: Step into")
set_leader_keymap("do", dap_conf.step_out,                       "DAP: Step out")
set_leader_keymap("dy", dap_conf.run_to_cursor,                  "DAP: Run to cursor")
set_leader_keymap("dc", dap_conf.continue,                       "DAP: Continue")
set_leader_keymap("dr", dap_conf.run_test_method,                "DAP: Run test method")
set_leader_keymap("t",  cmd_func("CopilotChatOpen"),             "Copilot: Open chat")
set_leader_keymap("e",  prep_to_edit_current_dir,                "Edit: file in buffer directory")
set_leader_keymap("fe", tele_find("find_files", get_buffer_dir), "Find: file in buffer directory")
set_leader_keymap("fE", tele_find("live_grep",  get_buffer_dir), "Find: in file in buffer directory")
set_leader_keymap("fn", tele_find("find_files", my_notes_dir),   "Find: Note")
set_leader_keymap("fN", tele_find("live_grep",  my_notes_dir),   "Find: In note")
set_leader_keymap("ff", tele_find("find_files", vim.fn.getcwd),  "Find: file in work directory")
set_leader_keymap("fF", tele_find("live_grep",  vim.fn.getcwd),  "Find: in file in work directory")
set_leader_keymap("ft", toggle_floaterm,                         "Term: Toggle floaterm")
set_for_filetype("floaterm", function()
	vim.keymap.set("n", "q",     toggle_floaterm, { silent = true, buffer = true })
	vim.keymap.set("n", "<C-j>", toggle_floaterm, { silent = true, buffer = true })
	vim.keymap.set("t", "<C-j>", toggle_floaterm, { silent = true, buffer = true })
end)

-- Insert mode
vim.keymap.set("i", "<C-p>", [[<C-r>+]], { desc = "Paste from clipboard" })
vim.keymap.set("i", "<C-c>", "<Esc>",    { desc = "Exit insert mode" })
vim.keymap.set("i", "<C-J>", "copilot#Accept('')", { expr = true, replace_keycodes = false })
vim.keymap.set("i", "<C-M>", "<Plug>(copilot-accept-word)")
vim.g.copilot_no_tab_map = true

-- Setup session manager
vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
local auto_session = require("auto-session")
auto_session.setup {
    log_level = "error",
    suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/"},
    auto_save = true,
    auto_restore = true,
}
EOF

" Required for operations modifying multiple buffers like rename
set hidden

set inccommand=nosplit

" Set yanking and putting to work with the systems clipboard
set clipboard+=unnamedplus

" copy indent from previous line: useful when using tabs for indentation and
" spaces for alignment
set copyindent
" For more info: https://dmitryfrank.com/articles/indent_with_tabs_align_with_spaces

" Better casing when searching (using `/` and `?`)
set ignorecase
set smartcase

set cursorline     " Highlight the current line

" When there is no `.editorconfig` file, default to use tabs and with a width
" of 4 characters
set shiftwidth=4
set tabstop=4
set noexpandtab

" More natural split opening
set splitbelow
set splitright

" Display white-spaces
set list listchars=tab:«-»,trail:·,nbsp:·,eol:⏎

" Disable arrow keys in normal mode - helps getting used to better movement keys
nnoremap <Left>  :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up>    :echoe "Use k"<CR>
nnoremap <Down>  :echoe "Use j"<CR>

" New tab: Control-T
nnoremap <C-T> :tabnew<CR>

" New terminal tab: Control-Shift-T
nnoremap <S-T> :tabnew<CR>:terminal<CR>A

" Vertical terminal split: Pipe ('|')
nnoremap <bar> :vsp<CR>:terminal<CR>A

" Horizontal terminal split: Underscore ('_')
nnoremap _ :sp<CR>:terminal<CR>A

" Exit terminal mode
tnoremap hj <C-\><C-n>

" Always use vertical diffs
set diffopt+=vertical

" Enable spell checking
set spell spelllang=en_us

highlight SpellBad ctermbg=001 ctermfg=007

" Remove compiled (and other) files form auto-complete
set wildignore+=*/tmp/*
set wildignore+=*/dist/*
set wildignore+=*/target/CACHEDIR.TAG
set wildignore+=*/target/debug/*
set wildignore+=*.so
set wildignore+=*.swp
set wildignore+=*.zip
set wildignore+=*.pyc
set wildignore+=*.class

set termguicolors

syntax enable

" Set a custom color-scheme based on the time of day
colorscheme NeoSolarized
func SelectBackground(timer)
	let theme_mode = trim(system('print_theme_mode'))
	if theme_mode == 'light-mode'
		set background=light
	elseif theme_mode == 'dark-mode'
		set background=dark
		highlight LineNr       guibg=#073642
		highlight CursorLine   guibg=#073642
		highlight CursorLineNr guibg=#002b36
	endif

	" "*bg=NONE" means "transparent"
	highlight Normal       guibg=NONE
	highlight NonText      guibg=NONE
	highlight SpellBad                   ctermbg=001       ctermfg=007

endfunc
let theme_timer = timer_start(60 * 1000, 'SelectBackground', {'repeat': -1})
call SelectBackground(theme_timer)
