" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    22


function! checksyntax#defs#java#Jlint() "{{{3
    let filename = expand('%:r') .'.class'
    let dirname = expand('%:h')
    return 'jlint +all -done -source '. shellescape(dirname) .' '. shellescape(filename)
endf


call checksyntax#AddChecker('java?',
            \ {
            \ 'name': 'jlint',
            \ 'if_executable': 'jlint',
            \ 'efm': '%m',
            \ 'cmdexpr': 'checksyntax#defs#java#Jlint()'
            \ },
            \ {
            \ 'if_executable': 'checkstyle',
            \ 'compiler': 'checkstyle',
            \ 'compiler_args': '%'
            \ })

