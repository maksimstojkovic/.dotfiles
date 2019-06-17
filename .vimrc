" Basic Settings

" Set compatibility
set nocompatible

" maintain undo history
set undofile
set undodir=~/.vim/undo
set noswapfile

" search highlighting
set hlsearch
set incsearch

" allow case insensitive search
set ignorecase
set smartcase
set infercase

" make backspace behave as expected
set backspace=indent,eol,start

" indentation settings
set shiftwidth=4
set tabstop=4
set softtabstop=4
set noexpandtab
set autoindent
set smartindent " might have to remove

" set leader to comma
let mapleader=","

" allow copy paste between programs
set clipboard+=unnamedplus

" remove trailing whitespaces on write
augroup ws
	autocmd!
	autocmd BufWritePre *.c,*.cpp,*.php,*.py,*.js,*.txt,*.sh,*.java,*.md,*.Rmd
				\ :call StripTrailingWhitespaces()
augroup end

" UI Config

" show matching brackets/parenthesis
set showmatch

" disable startup message
set shortmess+=I

" syntax highlighting
filetype plugin on
syntax on;
set synmaxcol=512

" show line numbers
set number
set relativenumber

" highlight cursor
set cursorline

" enable mouse
set mouse=a

" show invisibles
set list
set listchars=tab:»\ ,trail:~,extends:>,precedes:<,nbsp:+

" split style
set fillchars=vert:▒

" Functions and Key Mappings

" escape in insert mode
inoremap <leader>m <esc>

" remove highligting
nnoremap <silent> <leader><space> <esc>:nohlsearch<cr><esc>
nnoremap <silent> <esc><esc> <esc>:nohlsearch<cr><esc>

" highlight last inserted text
nnoremap gV `[v`]

" fix vertical navigation
nnoremap j gj
nnoremap k gk

" auto close curly braces
function! s:CloseBracket()
	let line = getline('.')
	if line =~# '^\s*\(struct\|class\|enum\) '
		return "{\<Enter>};\<Esc>O"
	elseif searchpair('(', '', ')', 'bmn', '', line('.'))
		" Probably inside a function call. Close it off.
		return "{\<Enter>});\<Esc>O"
	else
		return "{\<Enter>}\<Esc>O"
	endif
endfunction
inoremap <expr> {<Enter> <SID>CloseBracket()

" strips trailing whitespace at the end of all lines
function! StripTrailingWhitespaces()
	" save last search & cursor position
	let _s=@/
	let l = line(".")
	let c = col(".")
	%s/\s\+$//e
	let @/=_s
	call cursor(l, c)
endfunction

" Plugins

" install vim-plug (unix compatible only)
if empty(glob('~/.vim/autoload/plug.vim'))
	silent call system('mkdir -p ~/.vim/{autoload,bundle,cache,undo,backups,swaps}')
	silent call system('curl -fLo ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
	execute 'source  ~/.vim/autoload/plug.vim'
endif

call plug#begin('~/.vim/plugged')

" colour schemes
Plug 'sjl/badwolf'

" programming
Plug 'w0rp/ale'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'

" r-markdown
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-rmarkdown'
Plug 'dkarter/bullets.vim'


" features
Plug 'matze/vim-move'
Plug 'godlygeek/tabular'
Plug 'kien/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

" Plugin Settings

" set colour scheme
if !empty(glob('~/.vim/plugged/badwolf/colors/badwolf.vim'))
	colorscheme badwolf
endif

" r-markdown plugin readability
let g:pandoc#modules#disabled = ["folding", "spell"]
let g:pandoc#syntax#conceal#use = 0

" bullet point automation filetypes
let g:bullets_enabled_file_types = [
	\ 'markdown', 'rmarkdown', 'text'
\]

" use {H,J,K,L} to move lines
let g:move_key_modifier = 'S'

" gitgutter settings
let g:gitgutter_realtime = 1
let g:gitgutter_eager = 1
let g:gitgutter_max_signs = 1500
let g:gitgutter_diff_args = '-w'

" gitgutter custom symbols
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = ':'

" gitgutter color overrrides
highlight clear SignColumn
highlight GitGutterAdd ctermfg=green ctermbg=0
highlight GitGutterChange ctermfg=yellow ctermbg=0
highlight GitGutterDelete ctermfg=red ctermbg=0
highlight GitGutterChangeDelete ctermfg=red ctermbg=0

" airline settings
let g:airline_powerline_fonts = 1
