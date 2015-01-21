" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    17


call checksyntax#AddChecker('python?',
            \   {
            \     'cmd': 'flake8',
            \     'if_executable': 'flake8',
            \     'efm': '%f:%l:%c: %m',
            \     'convert_filename': checksyntax#MaybeUseCygpath('flake8'),
            \   },
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

