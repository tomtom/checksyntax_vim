" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    246

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


if !exists('g:checksyntax#defs#r#infix_operators')
    let g:checksyntax#defs#r#infix_operators = '\%([/^+-]\|<=\?\|>=\?\|<-\|==\?\|\*\*\?\|&&\?\|||\?\|%[[:alnum:]_!*/.@&$<=>+-]*%\)'   "{{{2
    " %\%(in\|||\|->\|T>\|<>\|--\|m+\|nin\|+replace\|tweak\|plan\|label\|globals\|has_\w\+\)%\|%s[=!+]\+%\|%[*/>.@&$u]\?%
endif


function! checksyntax#defs#r#FixSpaceAfterComma(...) abort "{{{3
    let l1 = a:0 >= 1 ? a:1 : 1
    let l2 = a:0 >= 2 ? a:2 : line('$')
    exec l1 .','. l2 's/,\zs\ze\S/ /ge'
endf


function! checksyntax#defs#r#FixSpaceAroundInfixOperators(...) abort "{{{3
    let l1 = a:0 >= 1 ? a:1 : 1
    let l2 = a:0 >= 2 ? a:2 : line('$')
    exec l1 .','. l2 's/\S\zs'. g:checksyntax#defs#r#infix_operators .'\ze\S/ \0 /ge'
endf


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
            \       'use_err_cb': 1,
            \     },
            \     'ignore_rx': g:checksyntax#defs#r#lintr_ignore_rx
            \   }
            \ )

