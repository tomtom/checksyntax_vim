" javascript.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-07-02.
" @Last Change: 2012-07-08.
" @Revision:    2


if !exists('g:checksyntax.javascript')
    let g:checksyntax['javascript'] = {
                \ 'alternatives': [
                \     {
                \         'cmd': 'gjslint',
                \         'ignore_nr': [1, 110],
                \         'efm': '%P%*[^F]FILE%*[^:]: %f %*[-],Line %l%\, %t:%n: %m,%Q',
                \     },
                \     {
                \         'cmd': 'jsl -nofilelisting -nocontext -nosummary -nologo -process',
                \     },
                \ ]
                \ }
endif


