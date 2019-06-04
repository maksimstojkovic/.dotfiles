colorscheme badwolf		" colour scheme

syntax enable			" enable syntax processing

" Indentation
filetype indent on			" load filetype specific indentation files from ~/.vim/indent/ directory
set tabstop=4				" spaces per TAB
set shiftwidth=4			" spaces per '>' indent
set softtabstop=4			" number of spaces in tab when editing
set expandtab				" converts TAB to spaces - for hard TAB use <Ctrl+V><Tab>

" UI Config
set number					" show line numbers
set relativenumber			" show relative line numbers for surrounding lines
set showcmd					" show last command on right side of bottom bar
set cursorline				" highlights current line
set wildmenu				" visual autocomplete list for command menu
set lazyredraw				" redraw screen only when required
set showmatch				" highlight matching brackets and parentheses

" Leader Shortcuts
let mapleader=","			" leader is comma
" remapping escape to ,m
inoremap <leader>m <esc>
" toggle graphical undo view
nnoremap <leader>u :GundoToggle<CR>
" open ag.vim for silver searcher quick search
nnoremap <leader>a :Ag

" Searching
set incsearch				" search as characters are entered
set hlsearch				" highlight matches
" turn off search highlighting
nnoremap <leader><space> :nohlsearch<CR>

" Folding
set foldenable				" enable folding
set foldlevelstart=10		" open most folds when opening buffer
set foldnestmax=10			" max number of nested folds
" space opens/closes folds
nnoremap <space> za
set foldmethod=indent		" fold based on indent level

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
    autocmd BufWritePre *.py,*.js,*.txt,*.sh,*.java,*.md
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

" strips trailing whitespace at the end of files. this
" is called on buffer write in the autogroup above.
function! StripTrailingWhitespaces()
    " save last search & cursor position
    let _s=@/
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    let @/=_s
    call cursor(l, c)
endfunction