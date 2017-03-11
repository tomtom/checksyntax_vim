" @Author:      Tom Link (micathom AT gmail com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2017-03-07.
" @Last Change: 2017-03-11.
" @Revision:    19

let s:cpo_save = &cpo
set cpo&vim

if exists('current_compiler')
    finish
endif
let current_compiler = 'perl_c'

if exists(':CompilerSet') != 2
    command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=perl\ -c\ %
CompilerSet errorformat=%-G%.%#had\ compilation\ errors.,%-G%.%#syntax\ OK,%m\ at\ %f\ line\ %l.,%+A%.%#\ at\ %f\ line\ %l\\,%.%#,%+C%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
