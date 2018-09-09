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
" Plug 'godlygeek/tabular'
" Plug 'ntpeters/vim-better-whitespace'
" Plug 'vim-scripts/Smart-Tabs'
Plug 'wellle/targets.vim'
Plug 'mhinz/vim-grepper'
Plug 'nelstrom/vim-visual-star-search'
Plug 'jreybert/vimagit'
Plug 'sbdchd/neoformat'
Plug 'danro/rename.vim'
Plug 'nvie/vim-flake8'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
call plug#end()


" Easy FS navigation commands
:command Forter    cd ~/dev/forter
:command Analytics cd ~/dev/forter/analytics/src
:command Pybolt    cd ~/dev/pybolts-infra
:command Velocity  cd ~/dev/velocity
:command Storm     cd ~/dev/forter/storm
:command Yasr      cd ~/dev/yasr

:command Workspace cd ~/workspace
:command Science   cd ~/science

:command Config    cd ~/.local/MyConfigs

" Easy Python term commands
:command Ipython terminal ipython2
:command Pytest  terminal pytest2


" Oni-specific settings
if exists("g:gui_oni")
    " Turn off statusbar, because it is externalized
    set noshowmode
    set noruler
    set noshowcmd
    "set laststatus=0 <- Uncommnet when Oni handles splits correctly

    " Enable GUI mouse behavior
    set mouse=a
endif

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
set list listchars=tab:»·,trail:·,nbsp:·

" Disable arrow keys in normal mode - helps getting used to better movement
" keys
nnoremap <Left>  gT
nnoremap <Right> gt
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
"tnoremap <bar> :vsp<CR>:terminal<CR>A

" Horizontal terminal split: Underscore ('_')
nnoremap _ :sp<CR>:terminal<CR>A
"tnoremap _ :sp<CR>:terminal<CR>A

nnoremap <C-I> :tabnew<CR>:terminal ipython2<CR>A

" Re-bind <C-f> for searching with grep (<C-d> is used for scrolling)
nnoremap <C-f> :GrepperGit 

" Exit terminal mode
tnoremap hj <C-\><C-n>

" Always use vertical diffs
set diffopt+=vertical

" Enable spell checking
set spell spelllang=en_us

highlight SpellBad ctermbg=001 ctermfg=007

" White-list YCM configuration files (not used since Oni has an LSP client)
"let g:ycm_extra_conf_globlist = ['~/workspace/*']

" Remove compiled Python files form auto-complete
set wildignore+=*.pyc

syntax enable

" Set a custom color-scheme
colorscheme NeoSolarized
set background=dark

