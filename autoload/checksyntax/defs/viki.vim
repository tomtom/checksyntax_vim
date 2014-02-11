" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    3


call checksyntax#AddChecker('viki?',
            \ {
            \ 'cmd': 'deplate -f null',
            \ }
            \ )


