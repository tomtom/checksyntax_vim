" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2012-08-28.
" @Revision:    3


if !exists('g:checksyntax.typescript')
    " For gjslint see https://developers.google.com/closure/utilities/docs/linter_howto
    let g:checksyntax['typescript'] = {
                \ 'alternatives': [
                \     {
                \         'name': 'tsc',
                \         'args': checksyntax#NullOutput('--out'),
                \         'if_executable': 'tsc',
                \         'compiler': 'typescript',
                \     },
                \ ]
                \ }
endif


