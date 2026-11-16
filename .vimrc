"" zhang 的 vimrc
set nocompatible
filetype plugin indent on
syntax enable
let mapleader = ","

set hidden
set confirm
set autoread
set backspace=indent,eol,start
set nobackup
set noswapfile
set nrformats-=octal
set nojoinspaces
set shortmess+=I
set path+=**

set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,big5,latin1

set ttimeout
set ttimeoutlen=10
set t_Co=256
set noerrorbells novisualbell

if has('clipboard')
  set clipboard=unnamed,unnamedplus
endif

set autoindent
set nowrap
set textwidth=0

augroup indent_by_ft
  autocmd!
  autocmd FileType c,cpp setlocal noexpandtab shiftwidth=8 tabstop=8 softtabstop=8
  autocmd FileType make  setlocal noexpandtab
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

set incsearch hlsearch ignorecase smartcase
nnoremap <silent> <leader>/ :nohlsearch<CR>

cnoremap w!! w !sudo tee % >/dev/null

augroup misc
  autocmd!
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
  autocmd BufWritePre * if &filetype !=# 'markdown' | call s:TrimTrailing() | endif
augroup END

function! s:TrimTrailing() abort
  let l:view = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:view)
endfunction
