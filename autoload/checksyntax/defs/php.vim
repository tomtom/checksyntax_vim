" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    12


call checksyntax#AddChecker('php?',
            \   {
            \     'name': 'php',
            \     'cmd': 'php -l -d display_errors=0 -d error_log= -d error_reporting=E_PARSE',
            \     'if_executable': 'php',
            \     'efm': '%*[^:]: %m in %f on line %l',
            \   }
            \ )

