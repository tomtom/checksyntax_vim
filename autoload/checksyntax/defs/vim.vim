" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    29


if !exists('g:checksyntax#defs#vim#ignore_rx')
    let g:checksyntax#defs#vim#ignore_rx = ''   "{{{2
endif


function! checksyntax#defs#vim#FixMissingFunctionAbortArgument(...) abort "{{{3
    let l1 = a:0 >= 1 ? a:1 : 1
    let l2 = a:0 >= 2 ? a:2 : line('$')
    exec l1 .','. l2 's/fu\%[nction]!\?\s\+.\{-})\zs\ze\%(\s\+\%(range\|dict\|closure\)\)*\%(\s*".*\)\?$/ abort/ge'
endf


call checksyntax#AddChecker('vim?',
            \ {
            \ 'compiler': 'checksyntax/vint',
            \ 'ignore_rx': g:checksyntax#defs#vim#ignore_rx,
            \ }
            \ )

