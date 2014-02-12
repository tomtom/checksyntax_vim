" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    4


call checksyntax#AddChecker('viki?',
            \ {
            \     'cmd': 'deplate -f null',
            \     'convert_filename': checksyntax#MaybeUseCygpath('deplate'),
            \ }
            \ )


