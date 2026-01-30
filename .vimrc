" Fix clipboard timeout on macOS
set clipboard=exclude:.*

set background=light
colorscheme solarized8_flat

au BufNewFile,BufRead *.go set filetype=go
au BufNewFile,BufRead *.md set filetype=markdown


command! Tabs set noexpandtab tabstop=4 shiftwidth=4
command! Spaces2 set expandtab softtabstop=2 shiftwidth=2
command! Spaces4 set expandtab softtabstop=4 shiftwidth=4
command! Spaces8 set expandtab softtabstop=2 shiftwidth=8
command! Tabs8 set tabstop==2 shiftwidth=8

Tabs
au Filetype cpp Spaces2
au Filetype javascript,javascript.jsx Spaces2
au Filetype python,markdown Spaces4

syntax on

set lazyredraw
set showmatch
set hlsearch

set directory^=/tmp//

filetype plugin indent on
set autoindent
set smartindent

set number
" set relativenumber

set ignorecase
set smartcase
set scrolloff=10

" FIX: Disable mouse to prevent clipboard timeout
" set mouse=nicr
set showcmd

set completeopt=preview

" Performance optimizations
set ttyfast
set regexpengine=1
set synmaxcol=200
set updatetime=300
set redrawtime=10000

"
nmap <space> <leader>
vmap <space> <leader>

inoremap jj <esc>
inoremap jJ <esc>
inoremap Jj <esc>
inoremap JJ <esc>

nnoremap ; :
vnoremap ; :
nnoremap <leader>w J
vnoremap <leader>a :w !xclip -sel clip<enter><enter>

nnoremap H gT
nnoremap L gt
nnoremap <C-h> H
nnoremap <C-l> L

nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

nnoremap gj j
nnoremap gk k
vnoremap gj j
vnoremap gk k


nnoremap J 8gj
nnoremap K 8gk
vnoremap J 8gj
vnoremap K 8gk

nnoremap gJ 8j
nnoremap gK 8k
vnoremap gJ 8j
vnoremap gK 8k

nnoremap <cr> o<esc>
nnoremap <C-a> <nop>
nnoremap <C-x> <nop>
