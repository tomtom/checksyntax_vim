" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    13


call checksyntax#AddChecker('python?',
            \   {
            \     'cmd': 'pyflakes',
            \     'efm': '%f:%l: %m',
            \   },
            \   {
            \     'cmd': 'pylint -r n -f parseable',
            \     'efm': '%f:%l: [%t] %m',
            \   }
            \ )

