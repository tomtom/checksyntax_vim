" @Author:      Tom Link (micathom AT gmail com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2017-03-07.
" @Last Change: 2017-03-11.
" @Revision:    24

let s:cpo_save = &cpo
set cpo&vim

if exists('current_compiler')
    finish
endif
let current_compiler = 'ruby_c'

if exists(':CompilerSet') != 2
    command -nargs=* CompilerSet setlocal <args>
endif

if !exists('g:checksyntax_ruby_cmd')
    let g:checksyntax_ruby_cmd = system('ruby --version')   "{{{2
endif


CompilerSet makeprg=ruby\ -c\ %
if g:checksyntax_ruby_cmd =~ '\<jruby'
    CompilerSet errorformat=SyntaxError\ in\ %f:%l:%m
else
    CompilerSet errorformat=
                \%+E%f:%l:\ parse\ error,
                \%W%f:%l:\ warning:\ %m,
                \%E%f:%l:in\ %*[^:]:\ %m,
                \%E%f:%l:\ %m,
                \%-C%\tfrom\ %f:%l:in\ %.%#,
                \%-Z%\tfrom\ %f:%l,
                \%-Z%p^,
                \%-G%.%#
endif


let &cpo = s:cpo_save
unlet s:cpo_save
