" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    24


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


let s:pmd = checksyntax#pmd#Cmd('ecmascript', checksyntax#defs#xml#pmd_args, checksyntax#defs#xml#pmd_rulesets)
if !empty(s:pmd)
    call checksyntax#AddChecker('xml?',
                \ {
                \ 'name': 'pmd',
                \ 'type': 'qfl',
                \ 'cmd': s:pmd,
                \ 'cmd_args': '',
                \ 'buffers': 'listed',
                \ 'efm': '%f:%l:%m',
                \ })
endif
unlet s:pmd

