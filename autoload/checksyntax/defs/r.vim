" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    204

" :doc:
" Syntax checkers for R:
" - lintr


if !exists('g:checksyntax#defs#r#progname')
    let g:checksyntax#defs#r#progname = executable('Rterm') ? 'Rterm' : 'R'   "{{{2
endif

if !executable(g:checksyntax#defs#r#progname)
    throw 'Please set g:checksyntax#defs#r#progname to the full filename of Rterm/R first!'
endif


" let g:checksyntax#defs#r#options = '--slave --restore --no-save -e "%s" --args'
if !exists('g:checksyntax#defs#r#options')
    let g:checksyntax#defs#r#options = '--slave --restore --no-save %s --args'   "{{{2
endif


if !exists('g:checksyntax#defs#r#lintr_ignore_rx')
    let g:checksyntax#defs#r#lintr_ignore_rx = ''   "{{{2
endif


" 'suppressWarnings(library("lintr"))', 
call checksyntax#AddChecker('r?',
            \   {
            \     'name': 'lintr',
            \     'cmd': g:checksyntax#defs#r#progname .' '.
            \         printf(g:checksyntax#defs#r#options, '-e "lintr::lint(commandArgs(TRUE))"'),
            \     'efm': '%W%f:%l:%c: style: %m,%W%f:%l:%c: warning: %m,%E%f:%l:%c: error: %m',
            \     'vim8': {
            \       'cmd': g:checksyntax#defs#r#progname .' '. printf(g:checksyntax#defs#r#options, ''),
            \       'input': ['lintr::lint(commandArgs(TRUE)); q()'],
            \     },
            \     'ignore_rx': g:checksyntax#defs#r#lintr_ignore_rx
            \   }
            \ )


