"""""""""""""""""""""""""""""""
" Essentials
"""""""""""""""""""""""""""""""
source ~/.vim/functions.vim

:set nocp
:syntax on
:set number
:set cindent
":set smartindent
:set nosmartindent " don't unindent '#' symbols
:set autoindent
:set ignorecase
:set smartcase
:set expandtab 
:set backspace=indent,eol,start
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set hidden
:set ruler
:filetype plugin on
:filetype on
:nohlsearch
:set noincsearch
:set backupskip=/tmp/*,/private/tmp/*
:set laststatus=2 " always show status line
syntax enable
" my preferred tab-completion (Bash-like)
:cnoremap <Tab>  <C-L><C-D>
source $HOME/.vim/autocorrect_custom.vim

autocmd! Bufenter *
autocmd! VimLeave *
autocmd! FileType *
autocmd! BufRead *

" cause clipboard register to be sync'd with the system clipboard on exit
autocmd VimLeave * call system("xsel -ib", getreg('+'))

" help set makeprg for out-of-source builds
call SetBaseMakeprg()
autocmd BufEnter * call SetMakeprgPath()
autocmd BufEnter * call SetupIncludeDirs()
autocmd BufEnter * call SetupPath()
autocmd BufEnter * call SetNeoMakeSearchPath()

:set mouse=a
if !has("nvim")
    execute pathogen#infect()
    if has("mouse_sgr")
        set ttymouse=sgr
    else
        set ttymouse=xterm2
    endif
endif

" path is actually set in SetupPath(), called at end of this script (and on
" every buffer switch)
let g:base_path=&path.',/usr/include/,/usr/local/include'

let g:base_cpp_incl = ['/usr/include/eigen3',
    \ '/usr/local/Cellar/opencv3/3.1.0_3/include',
    \ '/usr/local/include/eigen3']
call SetupIncludeDirs()

if has('nvim')
    command! Make Neomake! " build entire project
    autocmd! BufWritePost * Neomake " compile file on write

    let g:base_neomake_cpp_args = ['-c', 
    \           '-std=c++11',
    \           '-fopenmp',
    \           '-include'.$HOME.'/.vim/neomake/eos.h',
    \           '-Wall']

    " g:neomake_cpp_gcc_maker is setup here:
    " g:neomake_cpp_clang_maker is setup here:
    call SetNeoMakeSearchPath() 
else
    command! Make make
endif

:helptags ~/.vim/doc
":set tags+=~/.vim/tags/gl
:set tags+=~/.tags.d/cpp_std.tags
:set tags+=~/.tags.d/eigen3.tags
:set tags+=~/.tags.d/opencv.tags
:set tags+=~/.tags.d/mp_eos.tags


"""""""""""""""""""""
" Syntastic
""""""""""""""""""""""
let g:syntastic_c_include_dirs=['/usr/include/eigen3']

"""""""""""""""""""""
" Colors
""""""""""""""""""""""
" lifted from http://www.amix.dk/vim/vimrc.html

set gfn=Consolas:h12

if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
  set t_Co=256
endif

if has("gui_running")
  set guioptions-=T
  let psc_style='cool'
  colorscheme DimGrey
elseif &term=~'linux'
  colorscheme desert
  colorscheme evening
elseif &term=~'xterm' || &term=="nvim"
  if &diff
    colorscheme desert
  else 
    set background=dark
    colors elflord
  endif
endif

"Highlight current line
if has("gui_running")
  set cursorline
  hi cursorline guibg=#333333
  hi CursorColumn guibg=#333333
endif

"Omni menu colors
hi Pmenu guibg=#333333
hi PmenuSel guibg=#555555 guifg=#ffffff

" dark status line.  I can't read text if it's near a bright status line
hi StatusLine ctermbg=black ctermfg=lightgray


"""""""""""""""""""""""""""
" PLUGIN CUSTOMIZATION
"""""""""""""""""""""""""""
" Buffer explorer setup 
let g:miniBufExplModSelTarget = 1
let g:miniBufExplorerMoreThanOne = 0
let g:miniBufExplUseSingleClick = 1
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplVSplit = 25
let g:miniBufExplSplitBelow=1
" c-support plugin
let s:C_CodeSnippets   = '/home/ksimek/school/projects/boilerplate'

" command-t plugin
"let g:CommandTMaxDepth = 5
let g:ctrlp_max_depth = 5
:set wildignore+=*.o,*.a,build,test,Include_lines,Makefile*,dev,prod,*.jpg,*tiff,*tmp,*.bak
":set g:ctrlp_custom_ignore+=*.o,*.a,build,test,Include_lines,Makefile*,dev,prod,*.jpg,*tiff,*tmp,*.bak


"""""""""""""""""""""""""""""
" Recovery diff
"""""""""""""""""""""""""""""
" keep swap files in one place
set directory=~/.vim/swap,.
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis

""""""""""""""""""""""""""""""
"General Convenience maps
""""""""""""""""""""""""""""""
"   paste over without putting replaced text into buffer
vmap r "_dP
" quick commenting (see filetype-specific overrides below)
vmap // :s/^/#/<cr><esc>
vmap /// :s/^#//<cr><esc>
" sql Convenience maps
vmap -- :s/^/--/<cr><esc>
vmap --- :s/^--//<cr><esc>
" F2 - insert date, e.g.: 5/25/83
:imap <F2> <ESC>:read !date +\%D<CR>kJ
" underline current line
nmap <C-u> yyp:s/./-/g<CR>
" horizontal line
nmap <C-l> o<ESC>60a-<ESC>
autocmd FileType cpp nmap <C-l> o/* <ESC>74a-<ESC>a */
" KJB Convenience Maps
"nmap <leader>k :CommandT $KJB_LIB_PATH<cr>
nmap <leader>k :CtrlP $KJB_LIB_PATH<cr>
" TABS
nmap <leader>tn :tabnew %<cr>
nmap <leader>tc :tabclose<cr>
nmap <leader>tm :tabmove 
nmap <leader>tn :tabnext<cr>
nmap <leader>tp :tabnext<cr>
" next in quickfix
nmap <C-n> :cn<cr>
nmap <C-p> :cp<cr>
" window manager maps
nmap <c-w><c-f> :FirstExplorerWindow<cr>
nmap <c-w><c-b> :BottomExplorerWindow<cr> 
nmap <c-w><c-t> :WMToggle<cr>
" Sidebar toggles
nmap <leader>bt :TMiniBufExplorer<cr>
nmap <leader>tt :TlistToggle<cr>
nmap <leader>wt :WMToggle<cr>
" space toggles the fold state under the cursor.
nnoremap <silent><space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>
"""""""""""""""""""""""""""""
" RARELY USED MAPINGS (consider removing)
""""""""""""""""""""""""""""""
"   remove newlines from selected lines
vmap <backspace> :s/\n//g<cr>
" Fix ^M at eol 
:nmap <leader>rn :%s/\r/\r/g<cr>
"Some nice mapping to switch syntax (useful if one mixes different languages in one file)
map <leader>1 :set syntax=php<cr>
map <leader>2 :set syntax=xhtml<cr>
map <leader>3 :set syntax=css<cr>
map <leader>4 :set ft=javascript<cr>
map <leader>$ :syntax sync fromstart<cr>
imap <c-space> <c-x><c-o>


""""""""""""""""""""""""""""""""""""
"  Smart comment shortcuts
"""""""""""""""""""""""""""""""""""""
autocmd FileType c vmap // :s/^/\/\//<cr><esc>
autocmd FileType c vmap /// :s/\/\///<cr><esc>
autocmd FileType c nmap <leader>/* :s/\/\//\/*/<cr> :s/\s*$/ *\//<cr>
autocmd FileType c vmap <leader>/* :s/\/\//\/*/<cr> :'<,'>s/\s*$/ *\//<cr>

autocmd FileType cpp vmap // :s/^/\/\//<cr><esc>
autocmd FileType cpp vmap /// :s/\/\///<cr><esc>

autocmd FileType python vmap // :s/^/#/<cr><esc>
autocmd FileType python vmap /// :s/^#//<cr><esc>

autocmd FileType matlab vmap // :s/^/%/<cr><esc>
autocmd FileType matlab vmap /// :s/^%//<cr><esc>

autocmd BufRead *.tex vmap // :s/^/%/<cr><esc>
autocmd Bufread *.tex vmap /// :s/^%//<cr><esc>

"""""""""""""""""""""""""""""'
"  MISC
"""""""""""""""""""""""""
" run syntax-coloring refresh on entering a buffer
autocmd BufEnter * :syntax sync fromstart
""""""""""""""""""""
"  FILETYPE MAPPING
""""""""""""""""""""""""""
au BufRead,BufNewFile *.cl set filetype=opencl

" Latex setup
":set TTarget=pdf
let g:tex_flavor = "latex"

" Python setup
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class 
im :<CR> :<CR><TAB>
autocmd FileType python set nocindent

autocmd BufRead *.py set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
autocmd BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
autocmd BufRead *.py nmap <F5> :!python %<CR>

"""""""""""""""""""""""""""""
" Make customization
""""""""""""""""""""""""""""
set errorformat=%-GBuild\ start\ %m,
    \%-GBuild\ end\ %.%#,
    \%*[^\"]\"%f\"%*\\D%l:\ %m,
    \\"%f\"%*\\D%l:\ %m,
    \%-G%f:%l:\ (Each\ undeclared\ identifier\ is\ reported\ only\ once,
    \%-G%f:%l:\ for\ each\ function\ it\ appears\ in.),
    \%f(%l):%m,
    \%f:%l:%c:\ %trror:\ %m,
    \%f:%l:\ %trror:\ %m,
    \%f:%l:%c:\ %tarning:\ %m,
    \%f:%l:\ %tarning:\ %m,
    \%f:%l:%c:%m,
    \%f:%l:%m,
    \\"%f\"\\,
    \\ line\ %l%*\\D%c%*[^\ ]\ %m,
    \%D%*\\a[%*\\d]:\ Entering\ directory\ `%f',
    \%X%*\\a[%*\\d]:\ Leaving\ directory\ `%f',
    \%D%*\\a:\ Entering\ directory\ `%f',
    \%X%*\\a:\ Leaving\ directory\ `%f',
    \%DMaking\ %*\\a\ in\ %f,
    \%f\\|%l\|\ %m
set errorformat^=%-GIn\ file\ included\ from\ %f:%l:%c:,%-GIn\ file
                        \\ included\ from\ %f:%l:%c\\,,%-GIn\ file\ included\ from\ %f
                        \:%l:%c,%-GIn\ file\ included\ from\ %f:%l


""""""""""""""""""""
" Auto completion, Intellisense
"""""""""""""""""""""
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete

" circumvent vim's "pause 40 seconds while I thrash the disk" issue.
" set nofsync

" setup omnicppcomplete autocomplete for cpp files
" map <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
" 
" let OmniCpp_SelectFirstItem = 0
" let OmniCpp_NamespaceSearch = 1
" let OmniCpp_GlobalScopeSearch = 1
" let OmniCpp_ShowAccess = 1
" let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
" let OmniCpp_MayCompleteDot = 1
" let OmniCpp_MayCompleteArrow = 1
" let OmniCpp_MayCompleteScope = 1
" let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD", "kjb"]
" 
" au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menuone,menu,longest,preview
"

" CLANG AUTO-COMPLETE

"let g:clang_complete_auto = 1
let g:clang_complete_auto = 0
let g:clang_hl_errors = 1
let g:clang_user_options = '-fexceptions -fcxx-exceptions || exit 0'
let g:clang_complete_copen = 1
let g:clang_exec = 'clang++'
nmap <leader>u :call g:ClangUpdateQuickFix()<cr>

" this didn't stick when at the beginning of the file (only in neovim).  does  it stick now?
set nohlsearch

call SetupPath()
