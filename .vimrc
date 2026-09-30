"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set history=500
filetype on
filetype plugin on
filetype indent on
set autoread
set mouse=a
set encoding=UTF-8

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab
set smarttab
" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4
" Keep screen wrapping at word boundaries; format text to a maximum of 500 columns.
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable 


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set wildmenu
set wildmode=longest:full,full
set wildoptions+=tagfile,pum
" Older system Vims may not implement fuzzy command completion.
try
    set wildoptions+=fuzzy
catch /^Vim\%((\a\+)\)\=:E474/
endtry
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set ruler
set noshowmode

" Height of the command bar
set showcmd
set cmdheight=1

" A buffer becomes hidden when it is abandoned
set hidden
set ignorecase
set smartcase
set hlsearch
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw
set magic
set showmatch

"set spell
"autocmd BufRead,BufNewFile *.txt,*.log setlocal spell spelllang=en_us,en_gb

set number
set relativenumber
set scrolloff=8
"set list
"set listchars=eol:.,tab:>-,trail:~,extends:>,precedes:<

"if &term =~ xterm" || &term =~ screen" || &term =~ tmux"
 " let &t_SI = \e[1 q"  
  "let &t_EI = \e[5 q"  
  "let &t_SR = \e[3 q" 
"endif

"augroup myCmds
"au!
"autocmd VimEnter * silent !echo -ne \e[1 q"
"augroup END

"Cursor settings:

"  1 -> blinking block
"  2 -> solid block
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM key-bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
cnoreabbrev <expr> W getcmdtype() ==# ':' && getcmdline() ==# 'W' ? 'w' : 'W'
cnoreabbrev <expr> WQ getcmdtype() ==# ':' && getcmdline() ==# 'WQ' ? 'wq' : 'WQ'
cnoreabbrev <expr> wQ getcmdtype() ==# ':' && getcmdline() ==# 'wQ' ? 'wq' : 'wQ'
cnoreabbrev <expr> Q getcmdtype() ==# ':' && getcmdline() ==# 'Q' ? 'q' : 'Q'
cnoreabbrev <expr> Tabe getcmdtype() ==# ':' && getcmdline() ==# 'Tabe' ? 'tabe' : 'Tabe'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if !empty(globpath(&runtimepath, 'autoload/plug.vim'))
call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'itchyny/lightline.vim'
Plug 'ghifarit53/tokyonight-vim'

call plug#end()
endif

set termguicolors
if !has('gui_running')
    set t_Co=256
endif

let g:tokyonight_style = 'night' " available: night, storm
let g:tokyonight_enable_italic = 1

if !empty(globpath(&runtimepath, 'colors/tokyonight.vim'))
    colorscheme tokyonight
else
    colorscheme default
endif
let g:lightline = { 'colorscheme': 'tokyonight' }
set laststatus=2

let NERDTreeShowHidden=1
let NERDTreeRespectWildIgnore=1
let NERDTreeIgnore = ['\.DS_Store$', '\.min\.\(js\|css\)$', '^\.Trash','^\.cache','^\.cisco','^\.vnc','^\.vpn','^\.ossh','^\.oci','^\.vscode']

if executable('fd')
  let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
endif

let mapleader = " "
nnoremap <Leader>e :NERDTreeToggle<CR>
nnoremap <Leader>f :Files<CR>
nnoremap <Leader>b :Buffers<cr>
nnoremap <Leader>r :Rg<CR>
nnoremap <Leader>s :BLines<cr>
