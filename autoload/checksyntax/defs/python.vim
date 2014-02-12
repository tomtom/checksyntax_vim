" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    16


call checksyntax#AddChecker('python?',
            \   {
            \     'cmd': 'pyflakes',
            \     'if_executable': 'pyflakes',
            \     'efm': '%f:%l: %m',
            \     'convert_filename': checksyntax#MaybeUseCygpath('pyflakes'),
            \   },
            \   {
            \     'cmd': 'pylint -r n -f parseable',
            \     'if_executable': 'pylint',
            \     'efm': '%f:%l: [%t] %m',
            \     'convert_filename': checksyntax#MaybeUseCygpath('pylint'),
            \   }
            \ )

