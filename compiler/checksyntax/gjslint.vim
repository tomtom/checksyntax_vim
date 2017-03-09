" @Author:      Tom Link (micathom AT gmail com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2017-03-07.
" @Last Change: 2017-03-07.
" @Revision:    1

let s:cpo_save = &cpo
set cpo&vim

if exists("current_compiler")
    finish
endif
let current_compiler = 'gjslint'

if exists(":CompilerSet") != 2
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=gjslint\ --nosummary\ --unix_mode\ --nodebug_indentation\ --nobeep\ %
CompilerSet errorformat=%f:%l:(New\ Error\ -%\\?\%n)\ %m,%f:%l:(-%\\?%n)\ %m

let &cpo = s:cpo_save
unlet s:cpo_save
