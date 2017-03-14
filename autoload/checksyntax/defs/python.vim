" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    28


call checksyntax#AddChecker('python?',
            \   {
            \     'compiler': 'checksyntax/pylint',
            \   },
            \   {
            \     'compiler': 'checksyntax/flake8',
            \   },
            \   {
            \     'compiler': 'checksyntax/pyflakes',
            \   }
            \ )

