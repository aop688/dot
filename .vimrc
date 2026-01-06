""zhang 
"" Last update  2019-11-23

set nocompatible  " Disable vi-compatibility.
set encoding=utf-8 
set fileencodings=utf-8,gb18030,utf-16,big5
set confirm
set nobackup
set noswapfile
set bufhidden=hide
set ruler
set number
set comments=sl:/*,mb:\ *,elx:\ */
"set nowrap                      " don't wrap lines
filetype plugin indent on
set textwidth=180  " lines longer than 79 columns will be broken
"set formatoptions+=t
set shiftwidth=8  " operation >> indents 4 columns; << unindents 4 columns
"au BufRead,BufNewFile *.c setlocal textwidth=80
"au BufRead,BufNewFile *.py setlocal shiftwidth=4
set tabstop=8     " a hard TAB displays as 4 columns
set expandtab     " insert spaces when hitting TABs
set softtabstop=8 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
"set shiftround    " round indent to multiple of 'shiftwidth'
set autoindent    " align the new line indent with the previous line
set smartindent
set noerrorbells
set showmatch
set matchtime=2
set ignorecase
set nohlsearch
set incsearch
"set listchars=tab:\|\ ,trail:.,extends:>,precedes:<,eol:$
set scrolloff=3
set novisualbell
set t_Co=256

"" searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase 
nmap <silent> ,/ :nohlsearch<CR>


" set filename in Tmux tab
" @see http://stackoverflow.com/a/29693196/1935866
autocmd BufEnter * call system("tmux rename-window " . expand("%:t"))
autocmd VimLeave * call system("tmux rename-window bash")
autocmd BufEnter * let &titlestring = ' ' . expand("%:t")
set title

" List out all buffers
" @see http://of-vim-and-vigor.blogspot.com/p/vim-vigor-comic.html
nnoremap <leader>l :ls<CR>:b<space>

syntax enable
" colorscheme macvim

" edit multiple files
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 2
let g:netrw_winsize = 25

"More natural split opening
set splitbelow
set splitright

"instead of ctrl-w then hjkl, it’s just ctrl-hjkl
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
"nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>

if has("gui_running")
	set lines=60 columns=180
	set guifont="SF Mono:h13"
	"set guifont=Monaco:h11
    "set background=light
    colorscheme evening
endif

