" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    13

call checksyntax#AddChecker('sh?',
            \ {
            \ 'compiler': 'checksyntax/shellcheck',
            \ 'convert_filename': checksyntax#MaybeUseCygpath('spellcheck'),
            \ },
            \ {
            \ 'compiler': 'checksyntax/bash_n',
            \ 'convert_filename': checksyntax#MaybeUseCygpath('bash'),
            \ }
            \ )

