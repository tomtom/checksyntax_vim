" xml.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-07-02.
" @Last Change: 2012-07-02.
" @Revision:    15


if !exists('g:checksyntax.xml')
    let g:checksyntax['xml'] = {
                \ 'auto': 0,
                \ 'alternatives': [
                \   {
                \     'compiler': 'xmllint',
                \   }
                \ ]
                \ }
endif


