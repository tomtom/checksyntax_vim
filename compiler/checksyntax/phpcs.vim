" @Author:      Tom Link (micathom AT gmail com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2017-03-07.
" @Last Change: 2017-03-10.
" @Revision:    12

let s:cpo_save = &cpo
set cpo&vim

if exists('current_compiler')
    finish
endif
let current_compiler = 'phpcs'

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

if !exists('g:checksyntax_phpcs_cmd')
    " The phpcs command.
    let g:checksyntax_phpcs_cmd = 'phpcs'   "{{{2
endif

if !exists('g:checksyntax_phpcs_args')
    " For passing arguments into phpcs. Can be used to set options such 
    " as '--standard=PSR2 --ignore=foo.php'
    let g:checksyntax_phpcs_args = ''   "{{{2
endif

exec 'CompilerSet makeprg='. escape(g:checksyntax_phpcs_cmd .' '. g:checksyntax_phpcs_args .' %', '\ ')
CompilerSet errorformat=%f:%l:%*[^:]:\ %*[^-]-\ %m

let &cpo = s:cpo_save
unlet s:cpo_save
