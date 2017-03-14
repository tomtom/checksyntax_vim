" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    286


if !exists('g:checksyntax#defs#general#coala_cmd')
    let g:checksyntax#defs#general#coala_cmd = 'coala --json --find-config --files'   "{{{2
endif


if !empty(g:checksyntax#defs#general#coala_cmd)

    if !exists('g:checksyntax#defs#general#coala_filetypes')
        let g:checksyntax#defs#general#coala_filetypes = ['c', 'cpp', 'csharp', 'cmake', 'coffeescript', 'css', 'dart', 'fortran', 'go', 'haskell', 'html', 'java', 'javascript', 'jsp', 'tex', 'lua', 'markdown', 'perl', 'php', 'python', 'r', 'rst', 'ruby', 'scala', 'scss', 'sh', 'sql', 'swift', 'typescript', 'verilog', 'vhdl', 'vim', 'xml', 'yaml']   "{{{2
    endif


    function! checksyntax#defs#general#CoalaPreProcessOutput(lines) abort "{{{3
        let json = join(a:lines)
        let items = json_decode(json)
        let issues = []
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
        return issues
    endf


    call checksyntax#AddChecker('general?',
                \   {
                \     'name': 'coala',
                \     'inject': g:checksyntax#defs#general#coala_filetypes,
                \     'cmd': g:checksyntax#defs#general#coala_cmd,
                \     'efm': '%f:%l:%c: %m',
                \     'if': '!empty(findfile(".coafile", ".;"))',
                \     'preprocess_output': function('checksyntax#defs#general#CoalaPreProcessOutput'),
                \   }
                \ )

endif

