" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    9

if !exists('g:checksyntax#defs#scala#scalastyle')
    " The command to invoke scalastyle -- see http://www.scalastyle.org 
    " and especially http://www.scalastyle.org/command-line.html
    let g:checksyntax#defs#scala#scalastyle = ''   "{{{2
endif


if !empty(g:checksyntax#defs#scala#scalastyle)
    call checksyntax#AddChecker('scala?',
                \     {
                \         'name': 'scalastyle',
                \         'cmd': g:checksyntax#defs#scala#scalastyle,
                \         'efm': '%t%\\S%\\+ file=%f message=%m line=%l column=%c',
                \     },
                \ )
endif

