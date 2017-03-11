" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    32

call checksyntax#AddChecker('php?',
            \   {
            \     'compiler': 'checksyntax/php_lint',
            \   },
            \   {
            \     'compiler': 'checksyntax/phpcs',
            \   }
            \ )

