" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    6


call checksyntax#AddChecker('html?',
            \ {
            \ 'compiler': 'checksyntax/tidy',
            \ }
            \ )


