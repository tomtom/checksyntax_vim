" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    5


call checksyntax#AddChecker('tex?',
            \ {
            \   'compiler': 'chktex',
            \ }
            \ )


