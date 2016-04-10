" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    37

" Haxe checkers:
" - http://lib.haxe.org/p/haxelint/
" - http://lib.haxe.org/p/checkstyle/

if !exists('g:checksyntax#defs#haxe#haxe')
    " Filename of the haxe executable.
    let g:checksyntax#defs#haxe#haxe = executable('haxe') ? 'haxe' : ''   "{{{2
endif


if !exists('g:checksyntax#defs#haxe#hxml_files')
    let g:checksyntax#defs#haxe#hxml_files = ['compile.hxml', 'java.hxml', 'cpp.hxml', 'neko.hxml', 'js.hxml']   "{{{2
endif


if !exists('g:checksyntax#defs#haxe#use_checkstyle')
    " If true, use checkstyle (https://github.com/adireddy/haxe-checkstyle).
    let g:checksyntax#defs#haxe#use_checkstyle = 0   "{{{2
endif


if !exists('g:checksyntax#defs#haxe#checkstyle_args')
    " Additional arguments to checkstyle.
    " Can also be buffer-local as b:checksyntax_defs_haxe_checkstyle_args.
    let g:checksyntax#defs#haxe#checkstyle_args = ''   "{{{2
endif


" function! checksyntax#defs#haxe#Cmd() "{{{3
"     if empty(g:checksyntax#defs#haxe#haxe)
"         echohl Error
"         echom 'CheckSyntax: Please set g:checksyntax#defs#haxe#haxe!'
"         echohl NONE
"         return ''
"     endif
"     if exists(":HaxeCtags") == 2
"         let hxml = vaxe#CurrentBuild()
"     else
"         let hxml = findfile('compile.hxml', '.;')
"     endif
"     if empty(hxml)
"         echohl WarningMsg
"         echom 'CheckSyntax: compile.hxml not found!'
"         echohl NONE
"         let cmd = ''
"     else
"         let cmd = printf('%s -D no-compilation %s',
"                     \ g:checksyntax#defs#haxe#haxe,
"                     \ shellescape(hxml, 1))
"     endif
"     return cmd
" endf


function! checksyntax#defs#haxe#Gen(def) "{{{3
    if empty(g:checksyntax#defs#haxe#haxe)
        echohl Error
        echom 'CheckSyntax: Please set g:checksyntax#defs#haxe#haxe!'
        echohl NONE
        return ''
    endif
    let hxmls = []
    let chxml = ''
    if exists(":HaxeCtags") == 2
        let chxml = fnamemodify(vaxe#CurrentBuild(), ':p')
        if !empty(chxml)
            call add(hxmls, chxml)
        endif
    endif
    for hxml in g:checksyntax#defs#haxe#hxml_files
        let file_hxml = fnamemodify(findfile(hxml, '.;'), ':p')
        if file_hxml != chxml && filereadable(file_hxml)
            call add(hxmls, file_hxml)
        endif
    endfor
    " TLogVAR hxmls
    let checkers = {}
    if empty(hxmls)
        echohl WarningMsg
        echom 'CheckSyntax: compile.hxml not found!'
        echohl NONE
    else
        for hxml in hxmls
            let cmd = printf('%s -D no-compilation %s',
                        \ g:checksyntax#defs#haxe#haxe,
                        \ shellescape(hxml, 1))
            let checker = copy(a:def)
            let checker.cmd = cmd
            let name = fnamemodify(hxml, ':t')
            let checkers[name] = checker
        endfor
    endif
    " TLogVAR checkers
    return checkers
endf



function! checksyntax#defs#haxe#CmdCheckstyle() abort "{{{3
    if exists('b:checksyntax_defs_haxe_checkstyle_args')
        let args = b:checksyntax_defs_haxe_checkstyle_args
    else
        let args = g:checksyntax#defs#haxe#checkstyle_args
    endif
    return printf('haxelib run checkstyle %s -s', args)
endf


call checksyntax#AddChecker('haxe?',
            \ {
            \   'name': 'haxe',
            \   'listtype': 'qfl',
            \   'checkergen': 'checksyntax#defs#haxe#Gen',
            \   'cmd_args': '',
            \   'efm': '%f:%l: characters %c-%n : %m',
            \ },
            \ {
            \   'name': 'checkstyle',
            \   'listtype': 'qfl',
            \   'cmdexpr': 'checksyntax#defs#haxe#CmdCheckstyle()',
            \   'efm': '%f:%l:%c: %m',
            \   'if': g:checksyntax#defs#haxe#use_checkstyle,
            \ },
            \ )
            " \   'cmd': 'haxelib run checkstyle -s',
            " \   'cmdexpr': 'checksyntax#defs#haxe#Cmd()',

