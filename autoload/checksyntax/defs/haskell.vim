" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    27


call checksyntax#AddChecker('haskell?',
            \   {
            \     'cmd': 'hlint',
            \     'efm': '%A%f:%l:%c: %t%*[^:]: %m,%C%m',
            \     'convert_filename': checksyntax#MaybeUseCygpath('hlint'),
            \   },
            \   {
            \     'name': 'ghc-mod-check',
            \     'cmd': 'ghc-mod check',
            \     'efm': '%f:%l:%c:%m',
            \     'convert_filename': checksyntax#MaybeUseCygpath('ghc-mod'),
            \   },
            \ )

