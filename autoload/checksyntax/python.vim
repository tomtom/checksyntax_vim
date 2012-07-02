" python.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-07-02.
" @Last Change: 2012-07-02.
" @Revision:    1


if !exists('g:checksyntax.python')
    let g:checksyntax['python'] = {
                \ 'cmd': 'pyflakes',
                \ 'alt': 'pylint'
                \ }
endif

if !exists('g:checksyntax.pylint')
    let g:checksyntax['pylint'] = {
                \ 'compiler': 'pylint'
                \ }
endif


