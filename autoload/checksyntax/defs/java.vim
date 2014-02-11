" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    10


function! checksyntax#defs#java#Jlint() "{{{3
    let filename = expand('%:r') .'.class'
    " TLogVAR filename
    " echom '! jlint -done '. shellescape(filename)
    exec '! jlint -done '. shellescape(filename)
endf

call checksyntax#AddChecker('java?',
            \ {
            \ 'name': 'jlint',
            \ 'if_executable': 'jlint',
            \ 'exec': 'call checksyntax#defs#java#Jlint()'
            \ },
            \ {
            \ 'if_executable': 'checkstyle',
            \ 'compiler': 'checkstyle',
            \ 'compiler_args': '%'
            \ })

