" vim: ts=4 sw=4 et

function! neomake#makers#ft#objcpp#EnabledMakers() abort
    return executable('clang++') ? ['clang', 'clangtidy', 'clangcheck'] : ['gcc']
endfunction

function! neomake#makers#ft#objcpp#clang() abort
    let maker = neomake#makers#ft#c#clang()
    let maker.exe = 'clang++'
    return maker
endfunction

function! neomake#makers#ft#objcpp#gcc() abort
    let maker = neomake#makers#ft#c#gcc()
    let maker.exe = 'g++'
    return maker
endfunction

function! neomake#makers#ft#objcpp#clangtidy() abort
    return neomake#makers#ft#c#clangtidy()
endfunction

function! neomake#makers#ft#objcpp#clangcheck() abort
    return neomake#makers#ft#c#clangcheck()
endfunction
