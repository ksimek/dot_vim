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

function! GatherPathsFromFile(fname, ...)
    let paths_list = []
    if !filereadable(a:fname)
        return paths_list
    endif

    if a:0 == 0
        let cwd = ''
    else
        let cwd = a:1
    endif

    if cwd == ''
        let cwd = expand('%:p:h')
    endif

    for line in readfile(a:fname, '')
        if line[0] == '/'
            " Absolute filenames
            call add(paths_list, line)
        else
            " Relative filenames
            call add(paths_list, cwd . '/' . line)
        endif
    endfor
    return paths_list
endfunction

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
  elseif executable('/usr/sbin/sysctl')
    
    let n = system('/usr/sbin/sysctl -n hw.ncpu')
  else
    " default to single process if we can't figure it out automatically
    let n = 1
  endif
  let g:base_makeprg = 'make' . (n > 1 ? (' -j'.(n + 1)) : '')
endfunction

""""""""""""""""""""""""""""
" Out-of-source builds
""""""""""""""""""""""""""""
" My heuristic script that tries to identify the source root
" and the location of the build path. If found, it informs
" NeoMake's functionality, and is added to the Path (in SetupPath)
function! SetMakeprgPath()
    " get full path
    let current_path = expand('%:p:h')

    " TODO: make the next four blocks a loop over a list of filenames:
        
    let builddir = findfile('build/Makefile', current_path . ';')
    if !empty(builddir) 
        let g:build_path = fnamemodify(builddir, ':h')
        let &makeprg = g:base_makeprg . ' -C ' . g:build_path
        let g:src_path = fnamemodify(g:build_path, ':p:h:h')
        return
    endif

    let builddir = findfile('build/makefile', current_path . ';')
    if !empty(builddir) 
        let g:build_path = fnamemodify(builddir, ':h')
        let &makeprg = g:base_makeprg . ' -C ' . g:build_path
        let g:src_path = fnamemodify(g:build_path, ':p:h:h')
        return
    endif

    " if subdirectory is "build" check parent for cmakelist
    let builddir = findfile('Makefile', current_path . ';')
    if !empty(builddir)
        let g:build_path = fnamemodify(builddir, ':h')
        let &makeprg = g:base_makeprg . ' -C ' . g:build_path
        let g:src_path = g:build_path
        return
    endif

    " if subdirectory is "build" check parent for cmakelist
    let builddir = findfile('makefile', current_path . ';')
    if !empty(builddir)
        let g:build_path = fnamemodify(builddir, ':h')
        let &makeprg = g:base_makeprg . ' -C ' . g:build_path
        let g:src_path = g:build_path
        return
    endif

    " Out of source builds.  look for <path>-build in the same directory as
    " <path>
    while !empty(current_path) && current_path != '/'
        let current_dir = fnamemodify(current_path, ':t')
        let parent = fnamemodify(current_path, ':h')
        let build_dir = current_dir . '-build'
        if !empty(findfile(build_dir . '/Makefile', parent))
            let g:build_path = parent . '/' . build_dir
            let &makeprg = g:base_makeprg . ' -C ' . g:build_path
            let g:src_path = parent . '/' . current_dir
        return
            return
        endif
        let current_path = parent
    endwhile

    let &makeprg = g:base_makeprg
endfunction

function! SetupAlternativePath()
    if !exists('g:alternateSearchPathDefault')
        let g:alternateSearchPathDefault=g:alternateSearchPath
    endif
    let g:alternateSearchPath = g:alternateSearchPathDefault

    let current_path = expand('%:p:h')

    " Find any 'src' dir above current directory
    let src_path = finddir('src', current_path . ';', 1)
    if src_path != ''
        let g:alternateSearchPath = g:alternateSearchPath . ',abs:' . src_path
    endif

    " look for .alternate_dir.txt containing list of paths to search
    let fname=current_path . '/.alternate_paths.txt'
    for path in GatherPathsFromFile(fname)
        let g:alternateSearchPath = g:alternateSearchPath . ',abs:' . path
    endfor
endfunction

" setup a list of header search paths for c/c++ coding
function! SetupIncludeDirs()
    let g:cpp_incl = copy(g:base_cpp_incl)
    if exists("g:src_path")
        " Add project root
        :call add(g:cpp_incl, g:src_path)

        " check for file in project root that lists include paths
        let fname = g:src_path . '/.include_paths.txt'
        for path in GatherPathsFromFile(fname, g:src_path)
            call add(g:cpp_incl, path)
        endfor
    endif
    if exists("g:build_path")
        :call add(g:cpp_incl, g:build_path)
    endif
endfunction

" setup search path, which may change depending on the current script's path
" Note: call AFTER SetupIncludeDirs 
function! SetupPath()
    let &path = copy(g:base_path)
    for dir in g:cpp_incl
        let &path=&path.','.dir
    endfor 

    " check for file in cwd that lists paths to add
    " Note: if you already listed a path in .include_paths.txt, you 
    "       don't need to also include it in .paths.txt
    " TODO: consider checking for this in the project root, rather than cwd
    for path in GatherPathsFromFile('.paths.txt')
        let &path=&path.','.path
    endfor
endfunction

" setup neomake build parameters, which may change depending on the current
" script's path
function! SetNeoMakeSearchPath()
    if has('nvim')
        let l:neomake_args = copy(g:base_neomake_cpp_args)
        for dir in g:cpp_incl
            call add(neomake_args, '-I'.dir)
        endfor

        let g:neomake_cpp_gcc_maker = {
        \  'args': neomake_args,
        \  'bufferoutput': 1,
        \ }
    let g:neomake_cpp_clang_maker = copy(g:neomake_cpp_gcc_maker)

    let g:neomake_objcpp_enable_makers = ['clang']
    let g:neomake_objcpp_clang_maker = copy(g:neomake_cpp_gcc_maker)

    endif
endfunction

function! OnNeomakeJobFinished()
    let jobinfo = g:neomake_hook_context.jobinfo
    echo jobinfo.maker.name  . " exited with code " . jobinfo.exit_code
endfunction
