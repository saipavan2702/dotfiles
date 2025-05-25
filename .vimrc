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
" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax on


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set wildmenu
set wildmode=list
set wildoptions+=tagfile,pum,fuzzy
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
cmap W w
cmap WQ wq
cmap wQ wq
cmap Q q
cmap Tabe tabe


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ayu-theme/ayu-vim'

call plug#end()

set termguicolors
if !has('gui_running')
    set t_Co=256
endif
let ayucolor="dark"
colorscheme ayu

let g:airline_theme='ayu_dark'
let g:airline_powerline_fonts = 1
let g:airline_right_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_left_alt_sep= ''
let g:airline_left_sep = ''

" air-line
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

let g:Powerline_symbols = "fancy"
let g:Powerline_dividers_override = ["\Ue0b0","\Ue0b1","\Ue0b2","\Ue0b3"]
let g:Powerline_symbols_override = {'BRANCH': "\Ue0a0", 'LINE': "\Ue0a1", 'RO': "\Ue0a2"}
let g:airline_powerline_fonts = 1
let g:airline_right_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_left_alt_sep= ''
let g:airline_left_sep = ''

" air-line
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''


nnoremap <C-t> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeRespectWildIgnore=1
let NERDTreeIgnore = ['\.DS_Store$', '\.min\.(js|css)$', '^\.Trash','^\.cache','^\.cisco','^\.vnc','^\.vpn','^\.ossh','^\.oci','^\.vscode']

if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git/*"'
endif

let mapleader = ","
nnoremap \ :Rg<CR>
nnoremap <C-F> :Files<cr>
nnoremap <Leader>b :Buffers<cr>
nnoremap <Leader>s :BLines<cr>

"PlugInstall
"PlugUpdate
"PlugStatus
"PlugUpgrade
