" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    3


call checksyntax#AddChecker('tex?',
            \ {
            \ 'cmd': 'chktex -q -v0',
            \ 'if_executable': 'chktex',
            \ 'convert_filename': checksyntax#MaybeUseCygpath('chktex'),
            \ 'efm': '%f:%l:%m',
            \ }
            \ )


