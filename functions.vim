" vim:  ft=vim



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

:function! s:InitPaths()
:if filereadable('.paths')
:  let fname='.paths'
:  set path=.,/usr/include,,
:  for line in readfile(fname, '')
:  let &path=&path.','.line
:  endfor
:endif
endfu
:command! InitPaths call s:InitPaths() 
:InitPaths 

"""""""""""""""""""""""""""""
" Parallel make
"""""""""""""""""""""""""""""
function! SetBaseMakeprg()
  if !empty($NUMBER_OF_PROCESSORS)
    " this works on Windows and provides a convenient override mechanism otherwise
    let n = $NUMBER_OF_PROCESSORS + 0
  elseif filereadable('/proc/cpuinfo')
    " this works on most Linux systems
    let n = system('grep -c ^processor /proc/cpuinfo') + 0
  elseif executable('/usr/sbin/psrinfo')
    " this works on Solaris
    let n = system('/usr/sbin/psrinfo -p')
  else
    " default to single process if we can't figure it out automatically
    let n = 1
  endif
  let g:base_makeprg = 'make' . (n > 1 ? (' -j'.(n + 1)) : '')
endfunction

""""""""""""""""""""""""""""
" Out-of-source builds
""""""""""""""""""""""""""""
function! SetMakeprgPath()
    " get full path
    let current_path = expand('%:p:h')

    " TODO: make the next four blocks a loop over a list of filenames:
        
    let builddir = findfile('build/Makefile', current_path . ';')
    if !empty(builddir) 
        let &makeprg .= ' -C ' . builddir 
        return
    endif

    let builddir = findfile('build/makefile', current_path . ';')
    if !empty(builddir) 
        let &makeprg = g:base_makeprg . ' -C ' . builddir 
        return
    endif

    " if subdirectory is "build" check parent for cmakelist
    let builddir = findfile('Makefile', current_path . ';')
    if !empty(builddir)
        let &makeprg = g:base_makeprg . ' -C ' . builddir 
        return
    endif

    " if subdirectory is "build" check parent for cmakelist
    let builddir = findfile('makefile', current_path . ';')
    if !empty(builddir)
        let &makeprg = g:base_makeprg . ' -C ' . builddir 
        return
    endif

    while !empty(current_path) && current_path != '/'
        let current_dir = fnamemodify(current_path, ':t')
        let parent = fnamemodify(current_path, ':h')
        let build_dir = current_dir . '-build'
        if !empty(findfile(build_dir . '/Makefile', parent))
            let &makeprg = g:base_makeprg . ' -C ' . parent . '/' . build_dir
            return
        endif
        let current_path = parent
    endwhile

    let &makeprg = g:base_makeprg
endfunction
