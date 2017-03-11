" @Author:      Thomas Frowein (mailto:tfrowein AT gmx de?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    2


call checksyntax#AddChecker('go?',
            \ {
            \ 'cmd': 'go build %',
            \ }
            \ )

