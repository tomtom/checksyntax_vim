" ruby.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-07-02.
" @Last Change: 2012-07-08.
" @Revision:    2


if !exists('g:checksyntax.ruby')
    let g:checksyntax['ruby'] = {
                \ 'prepare': 'compiler ruby',
                \ 'cmd': 'ruby -c',
                \ }
endif


