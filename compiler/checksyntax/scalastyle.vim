" @Author:      Tom Link (micathom AT gmail com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2017-03-07.
" @Last Change: 2017-03-10.
" @Revision:    23

let s:cpo_save = &cpo
set cpo&vim

if exists('current_compiler')
    finish
endif
let current_compiler = 'scalastyle'

if exists(':CompilerSet') != 2
    command -nargs=* CompilerSet setlocal <args>
endif


if !exists('g:checksyntax_scalastyle_cmd')
    " The command to invoke scalastyle -- see http://www.scalastyle.org 
    " and especially http://www.scalastyle.org/command-line.html
    let g:checksyntax_scalastyle_cmd = ''   "{{{2
endif


if !exists('*CheckSyntaxScalaStyleCmd')
    function! CheckSyntaxScalaStyleCmd() abort "{{{3
        let build = findfile('build.sbt', '.;')
        if !empty(build)
            let config = fnamemodify(build, ':h') .'/scalastyle-config.xml'
            if filereadable(config)
                return 'sbt scalastyle'
            endif
        endif
        if !empty(g:checksyntax_scalastyle_cmd)
            return g:checksyntax_scalastyle_cmd .' %'
        endif
        return ''
    endf
endif

exec 'CompilerSet makeprg='. escape(CheckSyntaxScalaStyleCmd(), ' \')
CompilerSet errorformat=%t%\\\\S%\\\\+\ file=%f\ message=%m\ line=%l\ column=%c

let &cpo = s:cpo_save
unlet s:cpo_save
