" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    14


call checksyntax#AddChecker('perl?',
            \   {
            \     'cmd': 'perl -Wc %',
            \     'efm': '%-G%.%#had compilation errors.,%-G%.%#syntax OK,%m at %f line %l.,%+A%.%# at %f line %l\,%.%#,%+C%.%#',
            \     'convert_filename': checksyntax#MaybeUseCygpath('perl'),
            \   },
            \ )

