" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    31
"
" Other candidates:
" https://github.com/typelevel/wartremover
" https://github.com/sksamuel/scalac-scapegoat-plugin
" https://github.com/HairyFotr/linter
" https://github.com/sbt/cpd4sbt
" https://github.com/scala/scala-abide


if !exists('g:checksyntax#defs#scala#scalastyle')
    " The command to invoke scalastyle -- see http://www.scalastyle.org 
    " and especially http://www.scalastyle.org/command-line.html
    let g:checksyntax#defs#scala#scalastyle = ''   "{{{2
endif


if !exists('g:checksyntax#defs#scala#compiler')
    let g:checksyntax#defs#scala#compiler = 'fsc'   "{{{2
endif


if !exists('g:checksyntax#defs#scala#stop_after')
    " See `scalac -Xshow-phases` for possible values.
    let g:checksyntax#defs#scala#stop_after = 'cleanup'   "{{{2
endif


function! checksyntax#defs#scala#ScalaStyle() "{{{3
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
                \         'name': 'scala',
                \         'cmd': g:checksyntax#defs#scala#compiler .' -Ystop-after:'. g:checksyntax#defs#scala#stop_after,
                \         'efm': '%f:%l: %m',
                \     },
                \     {
                \         'name': 'scalastyle',
                \         'cmdexpr': 'checksyntax#defs#scala#ScalaStyle()',
                \         'efm': '%t%\\S%\\+ file=%f message=%m line=%l column=%c',
                \     },
                \ )
" endif

