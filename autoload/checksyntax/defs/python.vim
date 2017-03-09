" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    21


call checksyntax#AddChecker('python?',
            \   {
            \     'compiler': 'checksyntax/flake8',
            \     'convert_filename': checksyntax#MaybeUseCygpath('flake8'),
            \   },
            \   {
            \     'compiler': 'checksyntax/pyflakes',
            \     'convert_filename': checksyntax#MaybeUseCygpath('pyflakes'),
            \   },
            \   {
            \     'compiler': 'checksyntax/pylint',
            \     'convert_filename': checksyntax#MaybeUseCygpath('pylint'),
            \   }
            \ )

