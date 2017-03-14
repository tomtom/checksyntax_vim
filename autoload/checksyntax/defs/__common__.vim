" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    294


if !exists('g:checksyntax#defs#__common__#coala_cmd')
    let g:checksyntax#defs#__common__#coala_cmd = 'coala --json --find-config --files'   "{{{2
endif


if !empty(g:checksyntax#defs#__common__#coala_cmd) && exists('*json_decode')

    if !exists('g:checksyntax#defs#__common__#coala_filetypes')
        let g:checksyntax#defs#__common__#coala_filetypes = ['c', 'cpp', 'csharp', 'cmake', 'coffeescript', 'css', 'dart', 'fortran', 'go', 'haskell', 'html', 'java', 'javascript', 'jsp', 'tex', 'lua', 'markdown', 'perl', 'php', 'python', 'r', 'rst', 'ruby', 'scala', 'scss', 'sh', 'sql', 'swift', 'typescript', 'verilog', 'vhdl', 'vim', 'xml', 'yaml']   "{{{2
    endif


    function! checksyntax#defs#__common__#CoalaPreProcessOutput(lines) abort "{{{3
        let json = join(a:lines)
        let items = json_decode(json)
        let issues = []
        if type(items) == v:t_dict && has_key(items, 'results')
            for itemlist in values(items.results)
                for item in itemlist
                    for affected in item.affected_code
                        let issue = printf('%s:%d:%d: %s',
                                    \ affected.file,
                                    \ affected.start.line,
                                    \ affected.start.column,
                                    \ item.origin .': '. substitute(item.message, '\n', '|', 'g'))
                        call add(issues, issue)
                    endfor
                endfor
            endfor
        else
            echohl ErrorMsg
            echom 'CheckSyntax#coala: No results: '. string(json)
            echohl NONE
        endif
        return issues
    endf


    call checksyntax#AddChecker('__common__?',
                \   {
                \     'name': 'coala',
                \     'inject': g:checksyntax#defs#__common__#coala_filetypes,
                \     'cmd': g:checksyntax#defs#__common__#coala_cmd,
                \     'efm': '%f:%l:%c: %m',
                \     'use_err_cb': 1,
                \     'if': '!empty(findfile(".coafile", ".;"))',
                \     'preprocess_output': function('checksyntax#defs#__common__#CoalaPreProcessOutput'),
                \   }
                \ )

endif

