" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    146

" :doc:
" Syntax checkers for R:
"
"   codetools::checkUsageEnv ... Requires http://cran.r-project.org/web/packages/codetools/
"   lint::lint ... Requires http://cran.r-project.org/web/packages/lint/
"   svTools::lint ... Requires http://cran.r-project.org/web/packages/svTools/


if !exists('g:checksyntax#defs#r#progname')
    let g:checksyntax#defs#r#progname = executable('Rterm') ? 'Rterm' : 'R'   "{{{2
endif

if !executable(g:checksyntax#defs#r#progname)
    throw "Please set g:checksyntax#defs#r#progname to the full filename of Rterm/R first!"
endif


if !exists('g:checksyntax#defs#r#options')
    let g:checksyntax#defs#r#options = '--slave --ess --restore --no-save -e "%s" --args'   "{{{2
endif


if !exists('g:checksyntax#defs#r#checkUsage_options')
    " Optons passed to codetools::checkUsageEnv.
    " Must not be empty.
    let g:checksyntax#defs#r#checkUsage_options = 'all = TRUE'   "{{{2
endif


if !exists('g:checksyntax#defs#r#checkUsage_ignore_undefined_rx')
    " A |/\V| regexp pattern of names that should be ignored, when 
    " codetools::checkUsageEnv reports "no visible global function 
    " definition".
    let g:checksyntax#defs#r#checkUsage_ignore_undefined_rx = ''   "{{{2
endif


if !exists('g:checksyntax#defs#r#checkUsage_ignore_functions')
    " A list of function names that will be ignored when parsing the 
    " result list from codetools::checkUsageEnv.
    let g:checksyntax#defs#r#checkUsage_ignore_functions = []   "{{{2
endif


if !exists('g:checksyntax#defs#r#checkUsage_search_other_buffers')
    " If 2, also search other buffers for patterns returned by 
    " codetools::checkUsageEnv. This may cause unreponsive behaviour.
    "
    " If 1, show unidentifiable patterns as is.
    "
    " If 0, remove unidentifiable patterns.
    let g:checksyntax#defs#r#checkUsage_search_other_buffers = 0   "{{{2
endif


call checksyntax#AddChecker('r?',
            \   {
            \     'listtype': 'qfl',
            \     'name': 'codetools',
            \     'cmd': g:checksyntax#defs#r#progname .' '.
            \         printf(g:checksyntax#defs#r#options, 'try({library(codetools); source(commandArgs(TRUE)); checkUsageEnv(globalenv(),'. g:checksyntax#defs#r#checkUsage_options .')})'),
            \     'efm': '%m (%f:%l), %s : <anonymous>: %m, %s : %m, %s: %m',
            \     'process_list': 'checksyntax#defs#r#CheckUsageEnv'
            \   },
            \   {
            \     'name': 'lint',
            \     'cmd': g:checksyntax#defs#r#progname .' '.
            \         printf(g:checksyntax#defs#r#options, 'try(lint::lint(commandArgs(TRUE)))'),
            \     'efm': 'Lint: %m,%E%f:%l:%c,%Z%\\s\\+%m',
            \     'process_list': 'checksyntax#defs#r#LintLint'
            \   },
            \ )
            " \   {
            " \     'name': 'svTools::lint',
            " \     'cmd': g:checksyntax#defs#r#progname .' '.
            " \         printf(g:checksyntax#defs#r#options, 'try(svTools::lint(commandArgs(TRUE),type=''flat''))'),
            " \     'efm': '%t%\\w%\\++++%l+++%c+++%m',
            " \   }


" :nodoc:
function! checksyntax#defs#r#LintLint(list) "{{{3
    " TLogVAR a:list
    let list = []
    for issue in a:list
        let text = get(issue, 'text', '')
        if text =~ ': found on lines \d\+'
            let message = matchstr(text, '^.\{-}\ze: found on lines \d\+')
            let lines = split(matchstr(text, 'found on lines \zs\d\+.*$'), ', ')
            " TLogVAR message, lines
            for line in lines
                if line[0] =~ '^\d\+'
                    let issue1 = copy(issue)
                    let issue1.text = message
                    let issue1.lnum = str2nr(line)
                    call add(list, issue1)
                endif
            endfor
        else
            call add(list, issue)
        endif
    endfor
    " TLogVAR list
    return list
endf


" :nodoc:
function! checksyntax#defs#r#CheckUsageEnv(list) "{{{3
    " TLogVAR a:list
    let view = winsaveview()
    try
        let list = map(a:list, 's:CompleteCheckUsageEnvItem(v:val)')
        unlet! s:lnum s:bufnr
        let list = filter(list, '!empty(v:val)')
    finally
        call winrestview(view)
    endtry
    return list
endf


function! s:CompleteCheckUsageEnvItem(item) "{{{3
    " TLogVAR a:item
    let item = a:item
    let pattern = get(item, 'pattern', '')
    if !empty(g:checksyntax#defs#r#checkUsage_ignore_functions) && !empty(pattern)
        let ignored = filter(copy(g:checksyntax#defs#r#checkUsage_ignore_functions),
                    \ 'v:val =~ pattern')
        if len(ignored) > 0
            return {}
        endif
    endif
    if !empty(g:checksyntax#defs#r#checkUsage_ignore_undefined_rx) &&
                \ item.text =~ '\C\V\<no visible global function definition for '''. g:checksyntax#defs#r#checkUsage_ignore_undefined_rx .''''
        return {}
    endif
    " TLogVAR bufname(item.bufnr)
    if get(item, 'bufnr', 0) == 0 && !empty(pattern)
        let pattern = substitute(pattern, '\\\$', '\\>', '')
        let s:bufnr = bufnr('%')
        " let fn_rx = pattern .'\_s\*<-\_s\*function\_s\*('
        let fn_rx = pattern .'\_s\*<-\_s\*'
        let s:lnum = search(fn_rx, 'cwn')
        if s:lnum == 0 && g:checksyntax#defs#r#checkUsage_search_other_buffers == 2
            let bufnr0 = s:bufnr
            let view = winsaveview()
            try
                bufdo! if &ft == 'r' | let s:lnum = search(fn_rx, 'cwn') | if s:lnum > 0 | let s:bufnr = bufnr('%') | throw "ok" | endif | endif
            catch /ok/
            finally
                exec 'buffer' bufnr0
                call winrestview(view)
            endtry
        endif
        " TLogVAR pattern, s:lnum
        if s:lnum > 0
            let item.bufnr = s:bufnr
            let item.lnum = s:lnum
            let item.pattern = ''
            " TLogVAR item
        elseif g:checksyntax#defs#r#checkUsage_search_other_buffers == 1
            let item.pattern = pattern
        else
            return {}
        endif
    elseif bufname(item.bufnr) == '<Text>'
        return {}
    endif
    return item
endf

