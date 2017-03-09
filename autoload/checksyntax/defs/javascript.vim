" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    84


if !exists('g:checksyntax#defs#javascript#closure')
    " If non-empty, enable some checks via closure compiler.
    let g:checksyntax#defs#javascript#closure = ''   "{{{2
endif


if !exists('g:checksyntax#defs#javascript#closure_warnings')
    let g:checksyntax#defs#javascript#closure_warnings = ['const', 'constantProperty', 'checkRegExp', 'strictModuleDepCheck', 'visibility']   "{{{2
endif


if !exists('g:checksyntax#defs#javascript#pmd_rulesets')
    let g:checksyntax#defs#javascript#pmd_rulesets = ["basic", "braces", "unnecessary"]
endif


if !exists('g:checksyntax#defs#javascript#pmd_args')
    let g:checksyntax#defs#javascript#pmd_args = ''   "{{{2
endif


call checksyntax#AddChecker('javascript?',
            \     {
            \         'compiler': 'checksyntax/jshint',
            \     },
            \     {
            \         'compiler': 'checksyntax/esprima',
            \     },
            \     {
            \         'compiler': 'checksyntax/gjslint',
            \         'ignore_nr': [1, 110],
            \     },
            \     {
            \         'compiler': 'checksyntax/jslint',
            \     },
            \     {
            \         'compiler': 'checksyntax/jsl',
            \     },
            \ )

if !empty(g:checksyntax#defs#javascript#closure)
    if !empty(g:checksyntax#defs#javascript#closure_warnings)
        let s:closure_warnings = ' --jscomp_warning '. join(g:checksyntax#defs#javascript#closure_warnings, ' --jscomp_warning ')
    else
        let s:closure_warnings = ''
    endif
    call checksyntax#AddChecker('javascript?',
                \     {
                \         'name': 'closure',
                \         'cmd': g:checksyntax#defs#javascript#closure .' --warning_level VERBOSE '. checksyntax#NullOutput('--js_output_file') . s:closure_warnings,
                \         'efm': '%A%f:%l: %m,%-Cfound %#: %.%#,%+Crequired %#: %.%#,%-C%.%#,%-Z%p^',
                \     },
                \ )
    unlet s:closure_warnings
    " ,%-C%.%#,%+Z%p^
endif


if !empty(g:checksyntax#pmd#cmd)
    call checksyntax#AddChecker('javascript?',
                \ {
                \ 'name': 'pmd',
                \ 'type': 'qfl',
                \ 'cmdexpr': "checksyntax#pmd#Cmd('ecmascript', g:checksyntax#defs#javascript#pmd_args, g:checksyntax#defs#javascript#pmd_rulesets)",
                \ 'cmd_args': '',
                \ 'buffers': 'listed',
                \ 'efm': '%f:%l:%m',
                \ })
endif

