" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-07-02.
" @Last Change: 2012-08-28.
" @Revision:    28


if !exists('g:checksyntax.javascript')
    " For gjslint see https://developers.google.com/closure/utilities/docs/linter_howto
    let g:checksyntax['javascript'] = {
                \ 'alternatives': [
                \     {
                \         'name': 'jshint',
                \         'cmd': 'jshint --verbose',
                \         'efm': '%f: line %l\, col %c\, %m (%t%n)',
                \     },
                \     {
                \         'name': 'esprima',
                \         'cmd': 'esvalidate',
                \         'efm': '%f:%l: %m',
                \     },
                \     {
                \         'name': 'gjslint',
                \         'cmd': 'gjslint',
                \         'ignore_nr': [1, 110],
                \         'efm': '%P%*[^F]FILE%*[^:]: %f %*[-],Line %l%\, %t:%n: %m,%Q',
                \     },
                \     {
                \         'name': 'jslint',
                \         'cmd': 'jslint --terse',
                \         'efm': '%f:%l:%c: %m',
                \     },
                \     {
                \         'name': 'jsl',
                \         'cmd': 'jsl -nofilelisting -nocontext -nosummary -nologo -process',
                \     },
                \ ]
                \ }
endif


