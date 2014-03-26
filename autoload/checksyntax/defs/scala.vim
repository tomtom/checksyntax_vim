" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    18
"
" Other candidates:
" - wartremover https://github.com/typelevel/wartremover

if !exists('g:checksyntax#defs#scala#scalastyle')
    " The command to invoke scalastyle -- see http://www.scalastyle.org 
    " and especially http://www.scalastyle.org/command-line.html
    let g:checksyntax#defs#scala#scalastyle = ''   "{{{2
endif


function! checksyntax#defs#scala#Cmd() "{{{3
    let build = findfile('build.sbt', '.;')
    if !empty(build)
        let config = fnamemodify(build, ':h') .'/scalastyle-config.xml'
        if filereadable(config)
            return 'sbt scalastyle'
        endif
    endif
    if !empty(g:checksyntax#defs#scala#scalastyle)
        return g:checksyntax#defs#scala#scalastyle .' %'
    endif
    return ''
endf


" if !empty(g:checksyntax#defs#scala#scalastyle)
    call checksyntax#AddChecker('scala?',
                \     {
                \         'name': 'scalastyle',
                \         'cmdexpr': 'checksyntax#defs#scala#Cmd()',
                \         'cmd_args': '',
                \         'efm': '%t%\\S%\\+ file=%f message=%m line=%l column=%c',
                \     },
                \ )
" endif

