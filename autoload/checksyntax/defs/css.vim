" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    16

call checksyntax#AddChecker('css?',
            \ {
            \ 'compiler': 'csslint',
            \ 'compiler_args': '%',
            \ },
            \ )

