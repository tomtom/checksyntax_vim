" @Author:      Tom Link (micathom AT gmail com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2017-03-07.
" @Last Change: 2017-03-09.
" @Revision:    4

let s:cpo_save = &cpo
set cpo&vim

if exists("current_compiler")
    finish
endif
let current_compiler = 'pyflakes'

if exists(":CompilerSet") != 2
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=pyflakes\ %
CompilerSet errorformat=%f:%l:%c:\ %m

let &cpo = s:cpo_save
unlet s:cpo_save
