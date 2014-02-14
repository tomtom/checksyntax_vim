" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    3

if !exists('g:checksyntax#defs#scala#scalastyle')
    let g:checksyntax#defs#scala#scalastyle = ''   "{{{2
endif


if !empty(g:checksyntax#defs#scala#scalastyle)
    call checksyntax#AddChecker('scala?',
                \     {
                \         'name': 'scalastyle',
                \         'cmd': g:checksyntax#defs#scala#scalastyle,
                \         'efm': '%t%s file=%f message=%m line=%l column=%c,%Eerror file=%f message=%m line=%l column=%c',
                \     },
                \ )
endif

