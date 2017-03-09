" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    18


if !exists('g:checksyntax#defs#vim#ignore_rx')
    let g:checksyntax#defs#vim#ignore_rx = ''   "{{{2
endif


call checksyntax#AddChecker('vim?',
            \ {
            \ 'compiler': 'checksyntax/vint',
            \ 'ignore_rx': g:checksyntax#defs#vim#ignore_rx,
            \ }
            \ )

