" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    19


call checksyntax#AddChecker('haskell?',
            \   {
            \     'cmd': 'hlint %',
            \     'efm': '%A%f:%l:%c: %t%*[^:]: %m,%C%m',
            \     'convert_filename': checksyntax#MaybeUseCygpath('hlint'),
            \   },
            \ )

