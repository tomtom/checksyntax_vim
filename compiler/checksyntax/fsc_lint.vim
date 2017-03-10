" @Author:      Tom Link (micathom AT gmail com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2017-03-07.
" @Last Change: 2017-03-10.
" @Revision:    28

let s:cpo_save = &cpo
set cpo&vim

if exists('current_compiler')
    finish
endif
let current_compiler = 'fsc_lint'

if exists(':CompilerSet') != 2
    command -nargs=* CompilerSet setlocal <args>
endif


if !exists('g:checksyntax_fsc_lint_cmd')
    let g:checksyntax_fsc_lint_cmd = 'fsc'   "{{{2
endif


if !exists('g:checksyntax_fsc_lint_stop_after')
    " See `scalac -Xshow-phases` for possible values.
    let g:checksyntax_fsc_lint_stop_after = 'cleanup'   "{{{2
endif


exec 'CompilerSet makeprg='. escape(g:checksyntax_fsc_lint_cmd .' -Xlint -Ystop-after:'. g:checksyntax_fsc_lint_stop_after .' %', ' \')
CompilerSet errorformat=%f:%l:\ %m


let &cpo = s:cpo_save
unlet s:cpo_save
