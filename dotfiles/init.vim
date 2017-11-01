set nocompatible " be iMproved, required
filetype off     " required

"set termguicolors

" set the runtime path to include Vundle and initialize
set rtp+=~/.nvim/bundle/Vundle.vim


call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Don't enable YCM if Oni is the GUI since it uses LSPs
if !exists("g:gui_oni")
    Plugin 'Valloric/YouCompleteMe'
endif

Plugin 'editorconfig/editorconfig-vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'iCyMind/NeoSolarized'
" Plugin 'godlygeek/tabular'
" Plugin 'ntpeters/vim-better-whitespace'
" Plugin 'vim-scripts/Smart-Tabs'
Plugin 'wellle/targets.vim'
Plugin 'mhinz/vim-grepper'
Plugin 'nelstrom/vim-visual-star-search'
Plugin 'jreybert/vimagit'

" All of your Plugins must be added before the following line
call vundle#end()            " required

filetype plugin indent on    " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :plugininstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

" == Non-Plugin stuff ==

" Oni-specific settings
if exists("g:gui_oni")
    " Turn off statusbar, because it is externalized
    set noshowmode
    set noruler
    set laststatus=0
    set noshowcmd

    " Enable GUI mouse behavior
    set mouse=a
endif

" copy indent from previous line: useful when using tabs for indentation and spaces for alignment
set copyindent
" For more info: https://dmitryfrank.com/articles/indent_with_tabs_align_with_spaces

set ignorecase
set smartcase

set cursorline
set number
set relativenumber

set shiftwidth=4
set tabstop=4
set noexpandtab

" More natural split opening
set splitbelow
set splitright

" Display spaces
set list listchars=tab:»·,trail:·,nbsp:·

" Disable arrow keys
nnoremap <Left>  :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up>    :echoe "Use k"<CR>
nnoremap <Down>  :echoe "Use j"<CR>

" Set yanking and putting to work with the systems clipboard
set clipboard+=unnamedplus

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Always use vertical diffs
set diffopt+=vertical

" Enable spell checking
set spell spelllang=en_us

highlight SpellBad ctermbg=001 ctermfg=007

" White-list YCM configuration files
let g:ycm_extra_conf_globlist = ['~/workspace/*']

syntax enable
colorscheme NeoSolarized
set background=dark
