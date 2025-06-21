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

"if s:non_work_instance
	imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
	let g:copilot_no_tab_map = v:true
"endif


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


-- Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


-- Load my custom configuration
require("dap_conf")


vim.o.completeopt = "menu,menuone,noselect,noinsert,popup" -- Better completion experience


-- General nvim configs

vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    vim.wo.relativenumber = true -- Enable relative line numbers
  end,
  group = vim.api.nvim_create_augroup('TerminalLineNumbers', { clear = true }),
})


-- Setup nvim-cmp
local cmp = require'cmp'

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

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

require('lspconfig')['pylsp'].setup {
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

require('lspconfig').rust_analyzer.setup({})

require("CopilotChat").setup({})

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


-- Leader shortcuts
vim.api.nvim_set_keymap('n', '<leader>gd', [[<cmd>lua vim.lsp.buf.definition()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', '<leader>gD', [[<cmd>lua vim.lsp.buf.declaration()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sp', [[<cmd>Lspsaga preview_definition<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gr', [[<cmd>lua vim.lsp.buf.references()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', '<leader>gi', [[<cmd>lua vim.lsp.buf.implementation()<CR>]], { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>ca',  [[<cmd>Lspsaga code_action<CR>]],               { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rr',  [[<cmd>Lspsaga rename<CR>]],               { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sd',  [[<cmd>Lspsaga hover_doc<CR>]],            { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sh', [[<cmd>Lspsaga signature_help<CR>]],       { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>jn', [[<cmd>Lspsaga diagnostic_jump_next<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cp', [[<cmd>CopilotChatToggle<CR>]], { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>cs', [[<cmd>vsp ~/.local/work_configs/notes<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>vc', [[<cmd>vsp ~/.local/my_configs/dotfiles/init.vim<CR>]], { noremap = true, silent = true })

-- Formatting JSON
vim.api.nvim_set_keymap('n', '<leader>fj', [[<cmd>%!python -m json.tool --no-ensure-ascii<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<leader>fj', [[:!python -m json.tool --no-ensure-ascii<CR>]], { noremap = true, silent = true })

-- Formatting Python
local black_command = string.format(
  [[%s/bin/python -m black -q --line-length=%d --target-version=%s -]],
  vim.g.black_virtualenv,
  vim.g.black_linelength,
  vim.g.black_target_version
)
vim.api.nvim_set_keymap('n', '<leader>fp', [[:%!]] .. black_command .. [[<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<leader>fp', [[:!]] .. black_command .. [[<CR>]], { noremap = true, silent = true })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

-- Other shortcuts
vim.api.nvim_set_keymap('i', '<C-p>', [[<C-r>+]], { noremap = true, silent = true })


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

" <leader>e -- Edit file, starting in same directory as current file
nnoremap <leader>e :edit <C-R>=expand('%:h') . '/'<CR>
nnoremap <leader>E :edit <C-R>=expand('%:p:h') . '/'<CR>

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
set number         " Show line numbers
set relativenumber " Make the line numbers relative to the current line

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

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

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
