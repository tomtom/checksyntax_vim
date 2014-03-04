" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    16


if !exists('g:checksyntax#defs#php#cmd')
    let g:checksyntax#defs#php#cmd = 'php'   "{{{2
endif


if !exists('g:checksyntax#defs#php#args')
    let g:checksyntax#defs#php#args = '-l -d display_errors=0 -d error_log= -d error_reporting=E_ALL'   "{{{2
endif


call checksyntax#AddChecker('php?',
            \   {
            \     'name': 'php',
            \     'cmd': g:checksyntax#defs#php#cmd .' '. g:checksyntax#defs#php#args,
            \     'if_executable': g:checksyntax#defs#php#cmd,
            \     'convert_filename': checksyntax#MaybeUseCygpath(g:checksyntax#defs#php#cmd),
            \     'efm': '%*[^:]: %m in %f on line %l',
            \   }
            \ )

