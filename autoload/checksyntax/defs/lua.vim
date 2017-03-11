" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    9


call checksyntax#AddChecker('lua?',
            \ {
            \ 'compiler': 'checksyntax/luac_p',
            \ }
            \ )

