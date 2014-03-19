" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    17


if !exists('g:checksyntax#defs#haxe#haxe')
    " Filename of the haxe executable.
    let g:checksyntax#defs#haxe#haxe = executable('haxe') ? 'haxe' : ''   "{{{2
endif


function! checksyntax#defs#haxe#Cmd() "{{{3
    if empty(g:checksyntax#defs#haxe#haxe)
        echohl Error
        echom 'CheckSyntax: Please set g:checksyntax#defs#haxe#haxe!'
        echohl NONE
        return ''
    endif
    if exists(":HaxeCtags") == 2
        let hxml = vaxe#CurrentBuild()
    else
        let hxml = findfile('compile.hxml', '.;')
    endif
    if empty(hxml)
        echohl WarningMsg
        echom 'CheckSyntax: compile.hxml not found!'
        echohl NONE
        let cmd = ''
    else
        let cmd = printf('%s -D no-compilation %s',
                    \ g:checksyntax#defs#haxe#haxe,
                    \ shellescape(hxml, 1))
    endif
    return cmd
endf


call checksyntax#AddChecker('haxe?',
            \ {
            \   'name': 'haxe',
            \   'listtype': 'qfl',
            \   'cmdexpr': 'checksyntax#defs#haxe#Cmd()',
            \   'cmd_args': '',
            \   'efm': '%f:%l: characters %c-%n : %m',
            \ },
            \ )

