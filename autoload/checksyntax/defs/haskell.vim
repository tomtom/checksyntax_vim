" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    30


call checksyntax#AddChecker('haskell?',
            \   {
            \     'compiler': 'checksyntax/hlint',
            \   },
            \   {
            \     'compiler': 'checksyntax/ghc-mod-check',
            \   },
            \ )

