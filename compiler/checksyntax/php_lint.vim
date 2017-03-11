" @Author:      Tom Link (micathom AT gmail com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2017-03-07.
" @Last Change: 2017-03-10.
" @Revision:    8

let s:cpo_save = &cpo
set cpo&vim

if exists('current_compiler')
    finish
endif
let current_compiler = 'php_lint'

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

scriptencoding utf-8

if !exists('g:checksyntax_php_lint_cmd')
    let g:checksyntax_php_lint_cmd = 'php'   "{{{2
endif

if !exists('g:checksyntax_php_lint_args')
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
    let g:checksyntax_php_lint_args = '-l -n -d display_errors=1 -d error_log= -d error_reporting=E_ALL'   "{{{2
endif

exec 'CompilerSet makeprg='. escape(g:checksyntax_php_lint_cmd .' '. g:checksyntax_php_lint_args .' %', '\ ')
CompilerSet errorformat=%*[^:]:\ %m\ in\ %f\ on\ line\ %l

let &cpo = s:cpo_save
unlet s:cpo_save
