" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    5


call checksyntax#AddChecker('c?',
            \ {
            \ 'compiler': 'splint',
            \ 'if_executable': 'splint',
            \ 'convert_filename': checksyntax#MaybeUseCygpath('splint'),
            \ }
            \ )

