" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-07-02.
" @Last Change: 2012-08-28.
" @Revision:    45


if !exists('g:checksyntax#defs#javascript#closure')
    " If non-empty, enable some checks via closure compiler.
    let g:checksyntax#defs#javascript#closure = ''   "{{{2
endif


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
    if !empty(g:checksyntax#defs#javascript#closure)
        let g:checksyntax.javascript.alternatives += [
                    \     {
                    \         'name': 'checkTypes',
                    \         'cmd': g:checksyntax#defs#javascript#closure .' --warning_level VERBOSE --jscomp_warning checkTypes '. checksyntax#NullOutput('--js_output_file'),
                    \         'efm': '%A%f:%l: %m,%-Cfound %#: %.%#,%+Crequired %#: %.%#,%-C%.%#,%-Z%p^',
                    \     },
                    \ ]
        " ,%-C%.%#,%+Z%p^
    endif
endif


