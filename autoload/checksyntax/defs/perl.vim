" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    17


call checksyntax#AddChecker('perl?',
            \   {
            \     'compiler': 'checksyntax/perl_c',
            \   },
            \ )

