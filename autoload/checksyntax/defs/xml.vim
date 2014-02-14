" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    27


if !exists('checksyntax#defs#xml#pmd_rulesets')
    let checksyntax#defs#xml#pmd_rulesets = ["basic"]
endif


if !exists('checksyntax#defs#xml#pmd_args')
    let checksyntax#defs#xml#pmd_args = ''   "{{{2
endif


call checksyntax#AddChecker('xml?',
            \   {
            \     'compiler': 'xmllint',
            \     'compiler_args': '%',
            \     'convert_filename': checksyntax#MaybeUseCygpath('xmllint'),
            \   }
            \ )


if !empty(g:checksyntax#pmd#cmd)
    call checksyntax#AddChecker('xml?',
                \ {
                \ 'name': 'pmd',
                \ 'type': 'qfl',
                \ 'cmdexpr': "checksyntax#pmd#Cmd('xml', g:checksyntax#defs#xml#pmd_args, g:checksyntax#defs#xml#pmd_rulesets)",
                \ 'cmd_args': '',
                \ 'buffers': 'listed',
                \ 'efm': '%f:%l:%m',
                \ })
endif

