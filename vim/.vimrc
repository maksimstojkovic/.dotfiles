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
inoremap jk <esc>

" remove highligting
nnoremap <silent> <leader><space> <esc>:nohlsearch<cr><esc>

" highlight last inserted text
nnoremap gV `[v`]

" fix vertical navigation
nnoremap j gj
nnoremap k gk

" quick-save
nnoremap <leader><leader> <esc>:w<cr><esc>

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

" ale linting
let g:ale_completion_enabled = 1
let g:ale_sign_column_always = 1
let g:ale_lint_on_text_changed = 1
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1
let g:ale_sign_error = 'X'
let g:ale_sign_warning = '!'
highlight ALEErrorSign ctermbg=0 ctermfg=magenta
highlight ALEWarningSign ctermbg=0 ctermfg=yellow
let g:ale_echo_msg_format = '%linter%: %s'
let g:ale_c_clang_options = '-std=gnu11 -Wall'
let g:ale_c_gcc_options = '-std=gnu11 -Wall'

" r-markdown plugin readability
let g:pandoc#modules#disabled = ["folding", "spell"]
let g:pandoc#syntax#conceal#use = 0

" bullet point automation filetypes
let g:bullets_enabled_file_types = [
	\ 'markdown', 'rmarkdown', 'text'
\]

" use {H,J,K,L} to move lines
let g:move_key_modifier = 'C'

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

" airline settings (requires patched source code pro powerline font installed)
let g:airline_powerline_fonts = 1
set guifont=Source\ Code\ Pro\ for\ Powerline:h15:cANSI
let g:airline_theme='jellybeans'

" airline fallback symbols
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.maxlinenr = '㏑'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.whitespace = 'Ξ'

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = '' "  removed for readability
