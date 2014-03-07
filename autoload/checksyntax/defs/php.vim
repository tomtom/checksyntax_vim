" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    25


if !exists('g:checksyntax#defs#php#cmd')
    let g:checksyntax#defs#php#cmd = 'php'   "{{{2
endif


if !exists('g:checksyntax#defs#php#args')
    " Displaying errors for php files is surprisingly fragile since it 
    " depends on the php version and the php.ini file. If you get 
    " duplicate errors or no errors at all, change the command-line 
    " arguments defined with this variable. Please consider the 
    " information kindly collected by Björn Oelke:
    "
    "   Somehow the values in the php.ini and those passed via '--define' 
    "   seem to be independent, so either value in checksyntax' def file 
    "   seems to be a problem with one of the possible values in the 
    "   php.ini:
    "
    "   | cmd | php.ini | Errors |
    "   +-----+---------+--------+
    "   | 1   | On      | 2      |
    "   | 0   | On      | 1      |
    "   | 1   | Off     | 1      |
    "   | 0   | Off     | 0      |
    "
    "   There's an additional flag in the manpage called '--no-php-ini', 
    "   that could solve the problem.
    "
    " You can run `php -i | grep display_errors` to find out if 
    " display_errors is On because of the php.ini. By default, the 
    " setting in php.ini is ignored ("-n" command-line flag).
    let g:checksyntax#defs#php#args = '-l -n -d display_errors=1 -d error_log= -d error_reporting=E_ALL'   "{{{2
endif


call checksyntax#AddChecker('php?',
            \   {
            \     'name': 'php',
            \     'cmd': g:checksyntax#defs#php#cmd .' '. g:checksyntax#defs#php#args,
            \     'if_executable': g:checksyntax#defs#php#cmd,
            \     'convert_filename': checksyntax#MaybeUseCygpath(g:checksyntax#defs#php#cmd),
            \     'efm': '%*[^:]: %m in %f on line %l',
            \   }
            \ )

