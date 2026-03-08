" =============================================================================
" Basic Vimrc Configuration
" =============================================================================

" Enter the current millennium: ensures Vim doesn't operate in old vi-compatibility mode
set nocompatible

" Enable syntax highlighting and file type detection (essential for coding)
syntax enable
filetype plugin indent on

" Show line numbers
set number

" Highlight search results and show partial matches as you type
set hlsearch
set incsearch

" Ignore case when searching, unless the search pattern contains uppercase letters
set ignorecase
set smartcase

" Set tabs to be 4 spaces wide and use spaces instead of tabs
set tabstop=2
set shiftwidth=2
set expandtab

" Enable intelligent auto-indentation and smart indentation
set autoindent
set smartindent

" Show matching parentheses/brackets
set showmatch

" Allow unsaved files to be hidden when opening a new file
set hidden

" Always show the status line at the bottom
set laststatus=2

" Enable mouse support in all modes
" set mouse=a

" Use the system clipboard for copy and paste
" set clipboard=unnamedplus

" Remap 'jj' to escape for easier navigation
inoremap jj <Esc>

" Return to last edit position when reopening files (very useful!)
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Set the color scheme (you may need to install the scheme first)
" colorscheme solarized
" set background=dark

" Use a line cursor in insert mode and a block cursor otherwise
let &t_SI = "\e[6 q"   " ESC [ 6 q: vertical bar cursor (ibeam)
let &t_EI = "\e[2 q"   " ESC [ 2 q: steady block cursor
let &t_SR = "\e[4 q"   " ESC [ 4 q: steady underline cursor (for Replace mode)