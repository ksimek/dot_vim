"""""""""""""""""""""""""""""""
" Essentials
"""""""""""""""""""""""""""""""
execute pathogen#infect()
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
:set backupskip=/tmp/*,/private/tmp/*
:set laststatus=2 " always show status line
syntax enable
" my preferred tab-completion (Bash-like)
:cnoremap <Tab>  <C-L><C-D>

:set mouse=a
if has("mouse_sgr")
    set ttymouse=sgr
else
    set ttymouse=xterm2
end

:helptags ~/.vim/doc
:set tags+=~/.vim/tags/gl
:set tags+=~/.vim/tags/stl


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
elseif &term=~'xterm'
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


"""""""""""""""""""""""""""""""""""""""""
" :Shell command
"""""""""""""""""""""""""""""""""""""""""
" Executes a shell command and places result in a scratch buffer
command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)

function! s:RunShellCommand(cmdline)
  echo a:cmdline
  let expanded_cmdline = a:cmdline
  for part in split(a:cmdline, ' ')
     if part[0] =~ '\v[%#<]'
        let expanded_part = fnameescape(expand(part))
        let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
     endif
  endfor
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1, 'You entered:    ' . a:cmdline)
  call setline(2, 'Expanded Form:  ' .expanded_cmdline)
  call setline(3,substitute(getline(2),'.','=','g'))
  execute '$read !'. expanded_cmdline
  setlocal nomodifiable
  1
endfunction

"""""""""""""""""""""""""""""""""""""""""
" helper function to toggle hex mode
"""""""""""""""""""""""""""""""""""""""""
function! ToggleHex()
  " hex mode should be considered a read-only operation
  " save values for modified and read-only for restoration later,
  " and clear the read-only flag for now
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1

  if !exists("b:editHex") || !b:editHex
    " save old options
    let b:oldft=&ft
    let b:oldbin=&bin
    " set new options
    setlocal binary " make sure it overrides any textwidth, etc.
    let &ft="xxd"
    " set status
    let b:editHex=1
    " switch to hex editor
    %!xxd
  else
    " restore old options
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    " set status
    let b:editHex=0
    " return to normal editing
    %!xxd -r
  endif
  " restore values for modified and read only state
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction

" ex command for toggling hex mode - define mapping if desired
command! -bar Hexmode call ToggleHex()

nnoremap <leader>h :Hexmode<CR>
inoremap <C-H> <Esc>:Hexmode<CR>
vnoremap <C-H> :<C-U>Hexmode<CR>

"""""""""""""""""""""""""""""""""""""""""
" FUNCTION TO HANDLE BLAME FILES FROM SVN
"""""""""""""""""""""""""""""""""""""""""
""Show in a new window the Subversion blame annotation for the current file.
" Problem: when there are local mods this doesn't align with the source file.
" To do: When invoked on a revnum in a Blame window, re-blame same file up to previous rev.
:function! s:svnBlame()
   let line = line(".")
   setlocal nowrap
   aboveleft 18vnew
   setlocal nomodified readonly buftype=nofile nowrap winwidth=1
   NoSpaceHi
   " blame, ignoring white space changes
   %!svn blame -x-w "#"
   " find the highest revision number and highlight it
   "%!sort -n
   "normal G*u
   " return to original line
   exec "normal " . line . "G"
   setlocal scrollbind
   wincmd p
   setlocal scrollbind
   syncbind
:endfunction
:map <leader>bl :call <SID>svnBlame()<CR>
:command! Blame call s:svnBlame() 


"""""""""""""""""""""""""""
" Word processing mode
"""""""""""""""""""""""
cabbr wp call Wp()
fun! Wp()
  set lbr
  source $HOME/.vim/autocorrect.vim
  set guifont=Consolas:h14
  nnoremap j gj
  nnoremap k gk
  nnoremap 0 g0
  nnoremap $ g$
  set nonumber
  set spell spelllang=en_us
endfu


