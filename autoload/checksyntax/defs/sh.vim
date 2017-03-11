" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    14

call checksyntax#AddChecker('sh?',
            \ {
            \   'compiler': 'checksyntax/shellcheck',
            \ },
            \ {
            \   'compiler': 'checksyntax/bash_n',
            \ }
            \ )

