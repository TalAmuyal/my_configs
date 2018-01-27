if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"set termguicolors

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

call plug#end()


" Oni-specific settings
if exists("g:gui_oni")
    " Turn off statusbar, because it is externalized
    set noshowmode
    set noruler
    "set laststatus=0 <- Uncommnet when Oni handles splits correctly
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

" Exit terminal mode
tnoremap kj <C-\><C-n>

" Always use vertical diffs
set diffopt+=vertical

" Enable spell checking
set spell spelllang=en_us

highlight SpellBad ctermbg=001 ctermfg=007

" White-list YCM configuration files
"let g:ycm_extra_conf_globlist = ['~/workspace/*']

syntax enable
colorscheme NeoSolarized
set background=dark
