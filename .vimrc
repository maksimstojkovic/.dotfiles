" Colour scheme config
colorscheme badwolf         " colour scheme
" disable Background Colour Erase (BCE)
if &term =~ '256color'
	set t_ut=
endif

" enable syntax processing
syntax enable               " handled automatically by vim-plug

" enable filetype detection
filetype on

" automatically load file changes
set autoread

" Indentation
" load filetype specific indentation files from ~/.vim/indent/ directory
filetype plugin indent on   " handled automatically by vim-plug 
set tabstop=4               " spaces per TAB
set shiftwidth=4            " spaces per '>' indent
set softtabstop=4           " number of spaces in tab when editing
set noexpandtab             " do not convert TAB to spaces - for hard TAB use <Ctrl+V><Tab>

" UI Config
set number                  " show line numbers
set relativenumber          " show relative line numbers for surrounding lines
set showcmd                 " show last command on right side of bottom bar
set cursorline              " highlights current line
set wildmenu                " visual autocomplete list for command menu
set lazyredraw              " redraw screen only when required
set showmatch               " highlight matching brackets and parentheses
set ruler                   " show ruler in bottom right corner
set list                    " show whitespace characters
" make 'set list' visually nicer
if &listchars ==# 'eol:$'
	set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

" Encoding Config
" use utf-8 encoding
if &encoding ==# 'latin1' && has('gui_running')
	set encoding=utf-8
endif

" Leader Shortcuts
let mapleader=","           " leader is comma
" remapping escape to ,m
inoremap <leader>m <esc>
" toggle graphical undo view
nnoremap <leader>u :GundoToggle<CR>
" open ag.vim for silver searcher quick search
nnoremap <leader>a :Ag

" Searching
set incsearch               " search as characters are entered
set hlsearch                " highlight matches
" turn off search highlighting
nnoremap <leader><space> :nohlsearch<CR>

" Folding
set foldenable              " enable folding
set foldlevelstart=10       " open most folds when opening buffer
set foldnestmax=10          " max number of nested folds
" space opens/closes folds
nnoremap <space> za
set foldmethod=indent       " fold based on indent level

" Movement
" move vertically by visual line
nnoremap j gj
nnoremap k gk
" highlight last inserted text
nnoremap gV `[v`]

" Autogroups
augroup configgroup
	autocmd!
	autocmd VimEnter * highlight clear SignColumn
	autocmd BufWritePre *.py,*.js,*.txt,*.sh,*.java,*.md,*.Rmd
				\ :call StripTrailingWhitespaces()
augroup END

" toggle between number and relativenumber
function! ToggleNumber()
	if(&relativenumber == 1)
		set norelativenumber
	else
		set relativenumber
	endif
	set number
endfunc

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

" configuration for vim-pandoc and vim-rmarkdown
let g:pandoc#modules#disabled = ["folding", "spell"]
let g:pandoc#syntax#conceal#use = 0

" download vim-plug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
				\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" filetypes for bullet point automation
let g:bullets_enabled_file_types = [
	\ 'markdown',
	\ 'rmarkdown',
	\ 'text'
	\]

" install vim-plug plugins
call plug#begin('~/.vim/bundle')

" R-markdown plugins
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-rmarkdown'
Plug 'dkarter/bullets.vim'

call plug#end()

