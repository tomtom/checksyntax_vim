" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    4


call checksyntax#AddChecker('typescript?',
            \     {
            \         'name': 'tsc',
            \         'args': checksyntax#NullOutput('--out'),
            \         'if_executable': 'tsc',
            \         'compiler': 'typescript',
            \     }
            \ )


