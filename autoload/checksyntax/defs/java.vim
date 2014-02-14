" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    46


if !exists('checksyntax#defs#java#pmd_rulesets')
    " :read: let checksyntax#defs#java#pmd_rulesets = [...]   "{{{2
    let checksyntax#defs#java#pmd_rulesets = [
                \ "basic", "braces", "clone", "codesize", "comments", 
                \ "design", "empty", "finalizers", "imports", "javabeans", 
                \ "logging-jakarta-commons", "logging-java", "migrating", 
                \ "optimizations", "strictexception", "strings", 
                \ "sunsecure", "typeresolution", "unnecessary", 
                \ "unusedcode"]
    "android", "controversial", "coupling", "j2ee", "junit", "naming", 
endif


if !exists('checksyntax#defs#java#pmd_args')
    let checksyntax#defs#java#pmd_args = ''   "{{{2
endif


function! checksyntax#defs#java#Jlint() "{{{3
    let filename = expand('%:r') .'.class'
    let dirname = expand('%:h')
    return 'jlint +all -done -source '. shellescape(dirname) .' '. shellescape(filename)
endf


call checksyntax#AddChecker('java?',
            \ {
            \ 'if_executable': 'checkstyle',
            \ 'compiler': 'checkstyle',
            \ 'compiler_args': '%'
            \ })
            " \ {
            " \ 'name': 'jlint',
            " \ 'if_executable': 'jlint',
            " \ 'efm': '%m',
            " \ 'cmdexpr': 'checksyntax#defs#java#Jlint()'
            " \ },

if !empty(g:checksyntax#pmd#cmd)
    call checksyntax#AddChecker('java?',
                \ {
                \ 'name': 'pmd',
                \ 'type': 'qfl',
                \ 'cmdexpr': 'checksyntax#pmd#Cmd("java", g:checksyntax#defs#java#pmd_args, g:checksyntax#defs#java#pmd_rulesets)',
                \ 'cmd_args': '',
                \ 'buffers': 'listed',
                \ 'efm': '%f:%l:%m',
                \ })
endif

