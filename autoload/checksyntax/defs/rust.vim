" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    45


if !exists('g:checksyntax#defs#rust#args')
    let g:checksyntax#defs#rust#args = ''   "{{{2
endif


function! checksyntax#defs#rust#GuessCmd() "{{{3
    let cmd = 'rustc --no-trans --color never '
    let is_lib = len(filter(getline(1, '$'), 'v:val =~ ''^\s*fn main()''')) == 0
    if is_lib
        let cmd .= '--crate-type=lib '
    endif
    let cmd .= g:checksyntax#defs#rust#args
    return cmd
endf


" \     'efm': '%A%f:%l:%c: %m,%C%f %m,%-Z%p^',
call checksyntax#AddChecker('rust?',
            \   {
            \     'cmdexpr': 'checksyntax#defs#rust#GuessCmd()',
            \     'efm': '%f:%l:%c: %m',
            \   },
            \ )

