" Install the `plug` plugin-manager if it is missing
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Collect plugins
call plug#begin('~/.vim/plugged')
Plug 'editorconfig/editorconfig-vim'
Plug 'airblade/vim-gitgutter'
Plug 'iCyMind/NeoSolarized'
Plug 'wellle/targets.vim'
Plug 'nelstrom/vim-visual-star-search'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-dadbod'
Plug 'sheerun/vim-polyglot'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': 'bash install.sh'}
" Needed for LanguageClient-neovim:
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'meatballs/vim-xonsh'
Plug 'cespare/vim-toml'  " Support for highlighting toml filetype
Plug 'psf/black'
"Plug 'TalAmuyal/black', { 'branch': 'dev' }
"Plug '~/workspace/black'
Plug 'machakann/vim-highlightedyank'
call plug#end()

packadd! vimspector

" Set syntax of specific file name to specific file type
au BufNewFile,BufRead Pipfile      setf toml
au BufNewFile,BufRead Pipfile.lock setf json

let g:highlightedyank_highlight_duration = 300

let g:black_linelength=79
"autocmd BufWritePre *.py execute ':Black'

set shell=zsh

" Required for operations modifying multiple buffers like rename
set hidden
let g:LanguageClient_serverCommands = {
    \ 'python': ['~/.local/bin/pyls'],
    \ 'js': ['javascript-typescript-stdio'],
    \ }
" Use deoplete
let g:deoplete#enable_at_startup = 1

" Map Tab & Shift-Tab for cycling in menus
inoremap <silent><expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <silent><expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
" TODO: Fix completion selection using <ENTER>

" LSP
nnoremap <F1>          :call LanguageClient_contextMenu()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
nnoremap <silent> gd   :call LanguageClient#textDocument_definition()<CR>

" DAP
func RunDebugger()
	let file_name = expand('%:t')
	if file_name =~ '^test_.*\.py$'
		call vimspector#LaunchWithSettings( { 'configuration': 'test' } )
	elseif file_name =~ '.*\.py$'
		call vimspector#LaunchWithSettings( { 'configuration': 'src' } )
	else
		call vimspector#LaunchWithSettings( {  } )
	endif
endfunc
nmap <F3>   <Plug>VimspectorRestart
nmap <F4>   :VimspectorReset<CR>
nmap <F5>   :call RunDebugger()<CR>
nmap <F6>   <Plug>VimspectorToggleBreakpoint
nmap <F9>   <Plug>VimspectorStepInto
nmap <F10>  <Plug>VimspectorStepOver
nmap <F11>  <Plug>VimspectorStepOut

" Easy Python term commands
:command Pytest  terminal pytest2  " TODO: Run for folder of current file

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

nnoremap <C-I> :tabnew<CR>:terminal ipython2<CR>A

" Exit terminal mode
tnoremap hj <C-\><C-n>

" Always use vertical diffs
set diffopt+=vertical

" Enable spell checking
set spell spelllang=en_us

highlight SpellBad ctermbg=001 ctermfg=007

" Remove compiled files form auto-complete
set wildignore+=*.pyc
set wildignore+=*.class

set termguicolors

syntax enable

" Set a custom color-scheme based on the time of day
colorscheme NeoSolarized
func SelectBackground(timer)
	let hr = (strftime('%H'))
	if 19 > hr && hr > 8
		set background=light
	else
		set background=dark
	endif
endfunc
let theme_timer = timer_start(60 * 1000, 'SelectBackground', {'repeat': -1})
call SelectBackground(theme_timer)
