" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    1047


if !exists('g:checksyntax#auto_mode')
    " If 1, enable automatically running syntax checkers when saving a 
    " file if the syntax checker definitions has 'auto' == 1 (see 
    " |g:checksyntax|).
    " If 2, enforces automatic syntax checks for all known filetypes.
    " If 0, disable automatic syntax checks.
    let g:checksyntax#auto_mode = 1   "{{{2
endif


if !exists('g:checksyntax#debug')
    let g:checksyntax#debug = 0
endif


let s:top_level_fields = ['modified', 'auto', 'run_alternatives', 'alternatives']

if !exists('g:checksyntax')
    " A dictionary {name/filetype => definition} of syntax checkers, where 
    " definition is a dictionary with the following fields:
    " 
    " Mandatory (either one of the following):
    "   cmd ... A shell command used as 'makeprg' to check the file.
    "   exec ... A vim command used to check the file.
    "   compiler ... A vim compiler that is used to check the file.
    " 
    " Optional:
    "   auto* ...... Run automatically when saving a file (see also 
    "                |g:checksyntax#auto_mode|)
    "   efm  ....... An 'errorformat' string.
    "   prepare .... An ex command that is run before doing anything.
    "   ignore_nr .. A list of error numbers that should be ignored.
    "   listtype ... Either loc (default) or qfl
    "   include .... Include another definition
    "   process_list .. Process a list of issues
    "   if ......... An expression to test *once* whether a syntax checker 
    "                should be used.
    "   if_executable .. Test whether an application is executable.
    "   modified* .. If the buffer was modified, use an alternative 
    "                checker
    "   alternatives* ... A list of syntax checker definitions.
    "   run_alternatives* ... A string that defines how to run 
    "                alternatives (overrides 
    "                |g:checksyntax#run_alternatives|).
    "
    " The keys marked with "*" can be used only on the top level of a 
    " syntax checker definition.
    "
    " Pre-defined syntax checkers (the respective syntax checker has to 
    " be installed):
    "
    "   c, cpp       ... Requires splint
    "   html         ... Requires tidy
    "   java         ... Requires jlint or checkstyle
    "   javascript   ... Syntax check; requires jshint, esprima, 
    "                    gjslint, jslint, or jsl
    "   lua          ... Requires luac
    "   php          ... Syntax check; requires php
    "   python       ... Requires pyflakes or pylint
    "   r            ... Requires codetools::checkUsage, lint::lint, or 
    "                    svTools::lint
    "   ruby         ... Requires ruby
    "   tex, latex   ... Requires chktex
    "   viki         ... Requires deplate
    "   xhtml        ... Requires tidy
    "   xml, docbk   ... Requires xmllint
    "
    " Syntax checker definitions are kept in:
    " autoload/checksyntax/defs/{&filetype}.vim
    "
    " Run this command to find out, which filetypes are supported: >
    "   :echo globpath(&rtp, 'autoload/checksyntax/defs/*.vim')
    " :read: let g:checksyntax = {...}   "{{{2
    let g:checksyntax = {}
endif


if !exists('g:checksyntax#preferred')
    " A dictionary of 'filetype' => |regexp|.
    " If only one alternative should be run (see 
    " |g:checksyntax#run_alternatives|), check only those syntax 
    " checkers whose names matches |regexp|.
    let g:checksyntax#preferred = {'xml': '.'}   "{{{2
endif


if !exists('g:checksyntax#async_runner')
    " Supported values:
    "   asynccommand ... Use the Asynccommand plugin
    let g:checksyntax#async_runner = exists(':AsyncMake') ? 'asynccommand' : ''  "{{{2
endif


if !empty(g:checksyntax#async_runner)
    " Show status information (pending async tasks).
    command! CheckSyntaxStatus call s:Status()
endif


if !exists('g:checksyntax#run_alternatives')
    " How to handle alternatives. Possible values:
    "
    "     first ... Use the first valid entry
    "     all   ... Run all valid alternatives one after another
    "
    " Alternatively, the following flag can be added in order to change 
    " how the alternatives are run:
    "
    "     async ... Run alternatives asynchronously (see also 
    "               |g:checksyntax#async_runner|)
    let g:checksyntax#run_alternatives = 'first' . (!empty(g:checksyntax#async_runner) ? ' async' : '')   "{{{2
endif


if !exists('g:checksyntax#run_all_alternatives')
    " How to run "all" alternatives -- e.g., when calling the 
    " |:CheckSyntax| command with a bang.
    let g:checksyntax#run_all_alternatives = 'all' . (!empty(g:checksyntax#async_runner) ? ' async' : '')   "{{{2
endif


if !exists('g:checksyntax#windows')
    let g:checksyntax#windows = &shell !~ 'sh' && (has('win16') || has('win32') || has('win64'))   "{{{2
endif


if !exists('g:checksyntax#null')
    let g:checksyntax#null = g:checksyntax#windows ? 'nul' : (filereadable('/dev/null') ? '/dev/null' : '')    "{{{2
endif


if !exists('*CheckSyntaxSucceed')
    " This function is called when no syntax errors were found.
    function! CheckSyntaxSucceed(type, manually)
        call g:checksyntax#prototypes[a:type].Close()
        if a:manually
            echo
            echo 'Syntax ok.'
        endif
    endf
endif


if !exists('*CheckSyntaxFail')
    " This function is called when a syntax error was found.
    function! CheckSyntaxFail(type, manually, bg)
        " TLogVAR a:type, a:manually, a:bg
        call g:checksyntax#prototypes[a:type].Open(a:bg)
    endf
endif


if !exists('g:checksyntax#prototypes')
    " Contains prototype definitions for syntax checkers that use the 
    " |location-list| ("loc") or the |quixfix|-list.
    let g:checksyntax#prototypes = {'loc': {}, 'qfl': {}} "{{{2
endif

if empty(g:checksyntax#prototypes.loc)
    function! g:checksyntax#prototypes.loc.Close() dict "{{{3
        lclose
    endf

    function! g:checksyntax#prototypes.loc.Open(bg) dict "{{{3
        " TLogVAR a:bg
        lopen
        if a:bg
            wincmd p
        endif
    endf

    function! g:checksyntax#prototypes.loc.Make(args) dict "{{{3
        exec 'silent lmake!' a:args
    endf

    function! g:checksyntax#prototypes.loc.Get() dict "{{{3
        return copy(getloclist(0))
    endf

    function! g:checksyntax#prototypes.loc.Set(list) dict "{{{3
        call setloclist(0, a:list)
    endf
endif

if empty(g:checksyntax#prototypes.qfl)
    function! g:checksyntax#prototypes.qfl.Close() dict "{{{3
        cclose
    endf

    function! g:checksyntax#prototypes.qfl.Open(bg) dict "{{{3
        copen
        if a:bg
            wincmd p
        endif
    endf

    function! g:checksyntax#prototypes.qfl.Make(args) dict "{{{3
        exec 'silent make!' a:args
    endf

    function! g:checksyntax#prototypes.qfl.Get() dict "{{{3
        return copy(getqflist())
    endf

    function! g:checksyntax#prototypes.qfl.Set(list) dict "{{{3
        call setqflist(a:list)
    endf
endif


function! s:WithCompiler(compiler, exec, default) "{{{3
    if exists('g:current_compiler')
        let cc = g:current_compiler
    else
        let cc = ''
    endif
    try
        exec 'compiler '. a:compiler
        exec a:exec
    finally
        if cc != ''
            let g:current_compiler = cc
            exec 'compiler '. cc
        endif
    endtry
    return a:default
endf


function! s:Make(filetype, def)
    let bufnr = bufnr('%')
    let pos = getpos('.')
    let type = get(a:def, 'listtype', 'loc')
    try
        if has_key(a:def, 'compiler')

            return s:WithCompiler(a:def.compiler,
                        \ 'call g:checksyntax#prototypes[type].Make("")',
                        \ 1)

        else

            return checksyntax#Make(a:def)

        endif
    catch
        echohl Error
        echom "Exception" v:exception "from" v:throwpoint
        echom v:errmsg
        echohl NONE
    finally
        " TLogVAR pos, bufnr
        if bufnr != bufnr('%')
            exec bufnr 'buffer'
        endif
        call setpos('.', pos)
    endtry
    return 0
endf


" :nodoc:
" Run |:make| based on a syntax checker definition.
function! checksyntax#Make(def) "{{{3
    " TLogVAR a:def
    let type = get(a:def, 'listtype', 'loc')
    let makeprg = &makeprg
    let shellpipe = &shellpipe
    let errorformat = &errorformat
    if has_key(a:def, 'shellpipe')
        let &l:shellpipe = get(a:def, 'shellpipe')
        " TLogVAR &l:shellpipe
    endif
    if has_key(a:def, 'efm')
        let &l:errorformat = get(a:def, 'efm')
        " TLogVAR &l:errorformat
    endif
    try
        if has_key(a:def, 'cmd')
            let &l:makeprg = a:def.cmd
            " TLogVAR &l:makeprg
            call g:checksyntax#prototypes[type].Make(get(a:def, 'args', '%'))
            return 1
        elseif has_key(a:def, 'exec')
            exec a:def.exec
            return 1
        endif
    finally
        if &l:makeprg != makeprg
            let &l:makeprg = makeprg
        endif
        if &l:shellpipe != shellpipe
            let &l:shellpipe = shellpipe
        endif
        if &l:errorformat != errorformat
            let &l:errorformat = errorformat
        endif
    endtry
endf


let s:loaded_checkers = {}

" :nodoc:
function! checksyntax#Require(filetype) "{{{3
    if empty(a:filetype)
        return 0
    else
        if !has_key(s:loaded_checkers, a:filetype)
            exec 'runtime! autoload/checksyntax/defs/'. a:filetype .'.vim'
            let s:loaded_checkers[a:filetype] = 1
        endif
        return has_key(g:checksyntax, a:filetype)
    endif
endf


" :nodoc:
function! s:Cmd(def) "{{{3
    if has_key(a:def, 'cmd')
        let cmd = matchstr(a:def.cmd, '^\(\\\s\|\S\+\|"\([^"]\|\\"\)\+"\)\+')
        " TLogVAR cmd
        " let cmd = fnamemodify(cmd, ':t')
        " TLogVAR cmd
    else
        let cmd = ''
    endif
    return cmd
endf


" :nodoc:
function! checksyntax#Name(def) "{{{3
    let name = get(a:def, 'name', '')
    if empty(name)
        let name = get(a:def, 'compiler', '')
    endif
    if empty(name)
        let name = s:Cmd(a:def)
    endif
    return name
endf


let s:executables = {}

function! s:Executable(cmd) "{{{3
    if !has_key(s:executables, a:cmd)
        let s:executables[a:cmd] = executable(a:cmd) != 0
    endif
    return s:executables[a:cmd]
endf


function! s:ValidAlternative(def) "{{{3
    if has_key(a:def, 'if')
        return eval(a:def.if)
    elseif has_key(a:def, 'if_executable')
        return s:Executable(a:def.if_executable)
    else
        return 1
    endif
endf


function! s:GetValidAlternatives(filetype, run_alternatives, alternatives) "{{{3
    let valid = []
    for alternative in a:alternatives
        " TLogVAR alternative
        if s:ValidAlternative(alternative)
            if has_key(alternative, 'cmd')
                let cmd = s:Cmd(alternative)
                " TLogVAR cmd
                if !empty(cmd) && !s:Executable(cmd)
                    continue
                endif
            endif
            call add(valid, alternative)
            if a:run_alternatives =~? '\<first\>'
                break
            endif
        endif
    endfor
    return valid
endf


let s:run_alternatives_all = 0

" :nodoc:
function! checksyntax#RunAlternativesMode(def) "{{{3
    let rv = s:run_alternatives_all ? g:checksyntax#run_all_alternatives : get(a:def, 'run_alternatives', g:checksyntax#run_alternatives)
    " TLogVAR a:def, rv
    return rv
endf


function! s:GetDef(filetype) "{{{3
    " TLogVAR a:filetype
    if exists('b:checksyntax') && has_key(b:checksyntax, a:filetype)
        let dict = b:checksyntax
        let rv = b:checksyntax[a:filetype]
    elseif has_key(g:checksyntax, a:filetype)
        let dict = g:checksyntax
        let rv = g:checksyntax[a:filetype]
    else
        let dict = {}
        let rv = {}
    endif
    if !empty(dict)
        let alternatives = get(rv, 'alternatives', [])
        " TLogVAR alternatives
        if !empty(alternatives)
            let alternatives = s:GetValidAlternatives(a:filetype, checksyntax#RunAlternativesMode(rv), alternatives)
            " TLogVAR alternatives
            if len(alternatives) == 0
                let rv = {}
            else
                let rv = copy(rv)
                let rv.alternatives = alternatives
            endif
        endif
    endif
    return rv
endf


" :def: function! checksyntax#Check(manually, ?bang='', ?filetype=&ft, ?background=1)
" Perform a syntax check.
" If bang is not empty, run all alternatives (see 
" |g:checksyntax#run_alternatives|).
" If filetype is empty, the current buffer's 'filetype' will be used.
" If background is true, display the list of issues in the background, 
" i.e. the active window will keep the focus.
function! checksyntax#Check(manually, ...)
    let bang = a:0 >= 1 ? !empty(a:1) : 0
    let filetype   = a:0 >= 2 && a:2 != '' ? a:2 : &filetype
    let bg   = a:0 >= 3 && a:3 != '' ? a:3 : 0
    " TLogVAR a:manually, bang, filetype, bg
    let s:run_alternatives_all = bang
    try
        let defs = s:GetDefsByFiletype(a:manually, filetype)
        " TLogVAR defs
        if !empty(defs.make_defs)
            if !exists('b:checksyntax_runs')
                let b:checksyntax_runs = 1
            else
                let b:checksyntax_runs += 1
            endif
            " TLogVAR &makeprg, &l:makeprg, &g:makeprg, &errorformat
            if defs.run_alternatives =~? '\<first\>' && has_key(g:checksyntax#preferred, filetype)
                let preferred_rx = g:checksyntax#preferred[filetype]
                let defs.make_defs = filter(defs.make_defs, 'checksyntax#Name(v:val) =~ preferred_rx')
            endif
            let async = !empty(g:checksyntax#async_runner) && defs.run_alternatives =~? '\<async\>'
            if !empty(g:checksyntax#async_pending)
                if !a:manually && async
                    echohl WarningMsg
                    echo "CheckSyntax: Still waiting for async results ..."
                    echohl NONE
                    return
                else
                    let g:checksyntax#async_pending = {}
                endif
            endif
            let props = {
                        \ 'bg': bg,
                        \ 'bufnr': bufnr('%'),
                        \ 'filename': expand('%:p'),
                        \ 'manually': a:manually,
                        \ }
            let use_qfl = 0
            let all_issues = []
            let g:checksyntax#async_issues = []
            for [name, make_def] in items(defs.make_defs)
                " TLogVAR make_def, async
                let done = 0
                if async
                    let make_def1 = copy(make_def)
                    call extend(make_def1, props)
                    let make_def1.name = name
                    let make_def1.job_id = name .'_'. make_def1.bufnr
                    let done = s:Run_async(make_def1)
                endif
                if !done
                    let use_qfl += s:Run_sync(all_issues, name, filetype, make_def)
                endif
            endfor
            " echom "DBG 1" string(list)
            if empty(g:checksyntax#async_pending)
                if !empty(g:checksyntax#async_issues)
                    let all_issues += g:checksyntax#async_issues
                endif
                call checksyntax#HandleIssues(a:manually, use_qfl, bg, all_issues)
            else
                let g:checksyntax#async_issues += all_issues
            endif
        endif
    finally
        let s:run_alternatives_all = 0
    endtry
    redraw!
endf


function! s:Status() "{{{3
    if empty(g:checksyntax#async_pending)
        echo "CheckSyntax: No pending jobs"
    else
        echo "CheckSyntax: Pending jobs:"
        for [job_id, make_def] in items(g:checksyntax#async_pending)
            echo printf("  %s: bufnr=%s, cmd=%s",
                        \ job_id,
                        \ make_def.bufnr, 
                        \ make_def.name
                        \ )
        endfor
    endif
endf


function! s:GetDefsByFiletype(manually, filetype) "{{{3
    let defs = {'mode': '', 'make_defs': {}}
    call checksyntax#Require(a:filetype)
    let defs.mode = 'auto'
    let def = a:manually ? {} : s:GetDef(a:filetype .',auto')
    " TLogVAR 1, def
    if empty(def)
        let def = s:GetDef(a:filetype)
        " TLogVAR 2, def
    endif
    if &modified
        if has_key(def, 'modified')
            let defs.mode = 'auto'
            let def = s:GetDef(def.modified)
            " TLogVAR 3, def
        else
            echohl WarningMsg
            echom "Buffer was modified. Please save it before calling :CheckSyntax."
            echohl NONE
            return
        endif
    endif
    " TLogVAR def
    if empty(def)
        return defs
    endif
    if g:checksyntax#auto_mode == 0
        let auto = 0
    elseif g:checksyntax#auto_mode == 1
        let auto = get(def, 'auto', 0)
    elseif g:checksyntax#auto_mode == 2
        let auto = 1
    endif
    " TLogVAR auto
    if !(a:manually || auto)
        return defs
    endif
    let defs.run_alternatives = checksyntax#RunAlternativesMode(def)
    " TLogVAR &makeprg, &l:makeprg, &g:makeprg, &errorformat
    " TLogVAR def
    for make_def in get(def, 'alternatives', [def])
        let name = checksyntax#Name(make_def)
        " TLogVAR name, make_def
        let defs.make_defs[name] = make_def
    endfor
    return defs
endf


function! checksyntax#HandleIssues(manually, use_qfl, bg, all_issues) "{{{3
    let type = a:use_qfl > 0 ? 'qfl' : 'loc'
    if empty(a:all_issues)
        call g:checksyntax#prototypes[type].Set(a:all_issues)
        call CheckSyntaxSucceed(type, a:manually)
    else
        " TLogVAR all_issues
        call sort(a:all_issues, 's:CompareIssues')
        " TLogVAR all_issues
        call g:checksyntax#prototypes[type].Set(a:all_issues)
        " TLogVAR type, a:manually, a:bg
        call CheckSyntaxFail(type, a:manually, a:bg)
    endif
endf


function! s:CompareIssues(i1, i2) "{{{3
    let l1 = get(a:i1, 'lnum', 0)
    let l2 = get(a:i2, 'lnum', 0)
    " TLogVAR l1, l2, type(l1), type(l2)
    return l1 == l2 ? 0 : l1 > l2 ? 1 : -1
endf


let g:checksyntax#async_pending = {}
let g:checksyntax#async_issues = []


function! s:Run_async(make_def) "{{{3
    " TLogVAR a:make_def
    let make_def = a:make_def
    let cmd = ''
    if has_key(make_def, 'cmd')
        let cmd = get(make_def, 'cmd', '')
        let cmd .= ' '. shellescape(make_def.filename)
    elseif has_key(make_def, 'compiler')
        let compiler_def = s:WithCompiler(make_def.compiler,
                    \ 'return s:ExtractCompilerParams('. string(get(a:make_def, 'args', '')) .')',
                    \ {})
        " TLogVAR compiler_def
        if !empty(compiler_def)
            let cmd = compiler_def.cmd
            let make_def.efm = compiler_def.efm
        endif
    endif
    " TLogVAR cmd
    if !empty(cmd)
        try
            let rv = checksyntax#async#{g:checksyntax#async_runner}#Run(cmd, make_def)
            call checksyntax#AddJob(make_def)
            return rv
        catch /^Vim\%((\a\+)\)\=:E117/
            echohl Error
            echom 'Checksyntax: Unsupported value for g:checksyntax#async_runner: '. string(g:checksyntax#async_runner)
            echohl NONE
            let g:checksyntax#async_runner = ''
            return 0
        endtry
    else
        echohl WarningMsg
        echom "CheckSyntax: Cannot run asynchronously: ". make_def.name
        echohl NONE
        return 0
    endif
endf


function! s:ExtractCompilerParams(args) "{{{3
    let cmd = &makeprg
    if !empty(a:args) && stridx(cmd, '$*') == -1
        let cmd .= ' '. a:args
    endif
    let replaced = []
    if stridx(cmd, '%') != -1
        let cmd = substitute(cmd, '\V%', escape(expand('%:p'), '\'), 'g')
        call add(replaced, '%')
    endif
    if stridx(cmd, '$*') != -1
        if index(replaced, '%') == -1
            let cmd = substitute(cmd, '\V$*', a:args .' '. escape(expand('%:p'), '\'), 'g')
        else
            let cmd = substitute(cmd, '\V$*', a:args, 'g')
        endif
        call add(replaced, '$*')
    endif
    if stridx(cmd, '#') != -1
        let cmd = substitute(cmd, '\V%', escape(expand('#:p'), '\'), 'g')
        call add(replaced, '#')
    endif
    let compiler_def = {
                \ 'cmd': cmd,
                \ 'efm': &errorformat
                \ }
    return compiler_def
endf


let s:status_expr = 'checksyntax#Status()'


function! checksyntax#AddJob(make_def) "{{{3
    let g:checksyntax#async_pending[a:make_def.job_id] = a:make_def
    if exists('g:tstatus_exprs')
        if index(g:tstatus_exprs, s:status_expr) == -1
            call add(g:tstatus_exprs, s:status_expr)
        endif
    endif
endf


function! checksyntax#RemoveJob(job_id) "{{{3
    let rv = has_key(g:checksyntax#async_pending, a:job_id)
    if rv
        call remove(g:checksyntax#async_pending, a:job_id)
        if empty(g:checksyntax#async_pending) && exists('g:tstatus_exprs')
            let idx = index(g:tstatus_exprs, s:status_expr)
            if idx != -1
                call remove(g:tstatus_exprs, idx)
            endif
        endif
    endif
    return rv
endf


function! checksyntax#Status() "{{{3
    let n = len(g:checksyntax#async_pending)
    if n == 0
        return ''
    else
        return 'PendingChecks='. n
    endif
endf


function! s:Run_sync(all_issues, name, filetype, def) "{{{3
    " TLogVAR a:name, a:filetype, a:def
    let use_qfl = 0
    let def = a:def
    if has_key(def, 'include')
        let include = s:GetDef(def.include)
        if !empty(include)
            let def = extend(copy(def), include, 'keep')
        endif
    endif
    exec get(def, 'prepare', '')
    if s:Make(a:filetype, def)
        let type = get(def, 'listtype', 'loc')
        if type != 'loc'
            let use_qfl = 1
        endif
        let list = checksyntax#GetList(a:name, def, type)
        if !empty(list)
            call extend(a:all_issues, list)
        endif
    endif
    return use_qfl
endf


function! checksyntax#GetList(name, def, type) "{{{3
    let list = g:checksyntax#prototypes[a:type].Get()
    " TLogVAR a:type, list
    " TLogVAR 1, len(list)
    if !empty(list) && has_key(a:def, 'process_list')
        let list = call(a:def.process_list, [list])
        " TLogVAR 2, len(list)
    endif
    if !empty(list)
        let list = filter(list, 's:FilterItem(a:def, v:val)')
        " TLogVAR 3, len(list)
        " TLogVAR a:type, list
        if !empty(list)
            let list = map(list, 's:CompleteItem(a:name, a:def, v:val)')
            " TLogVAR 4, len(list)
            " TLogVAR a:type, list
        endif
    endif
    return list
endf


function! s:CompleteItem(name, def, val) "{{{3
    " TLogVAR a:name, a:def, a:val
    if get(a:val, 'bufnr', 0) == 0
        let a:val.bufnr = bufnr('%')
    endif
    let text = get(a:val, 'text', '')
    let a:val.text = substitute(text, '^\s\+\|\s\+$', '', 'g')
    let type = get(a:val, 'type', '')
    if !empty(type)
        let a:val.text = printf('[%s] %s', type, a:val.text)
    endif
    if !empty(a:name)
        let text = get(a:val, 'text', '')
        if !empty(text)
            let a:val.text = a:name .': '. text
        endif
    endif
    " TLogVAR a:val
    return a:val
endf


function! s:FilterItem(def, val) "{{{3
    if a:val.lnum == 0 && a:val.pattern == ''
        return 0
    elseif has_key(a:val, 'nr') && has_key(a:def, 'ignore_nr') && index(a:def.ignore_nr, a:val.nr) != -1
        return 0
    endif
    return 1
endf


" :nodoc:
" :display: checksyntax#CopyFunction(old, new, overwrite=0)
function! checksyntax#CopyFunction(old, new, ...) "{{{3
    let overwrite = a:0 >= 1 ? a:1 : 0
    redir => oldfn
    exec 'silent function' a:old
    redir END
    if exists('*'. a:new)
        if overwrite > 0
            exec 'delfunction' a:new
        elseif overwrite < 0
            throw 'checksyntax#CopyFunction: Function already exists: '. a:old .' -> '. a:new
        else
            return
        endif
    endif
    let fn = split(oldfn, '\n')
    let fn = map(fn, 'substitute(v:val, ''^\d\+'', "", "")')
    let fn[0] = substitute(fn[0], '\V\^\s\*fu\%[nction]!\?\s\+\zs'. a:old, a:new, '')
    let t = @t
    try
        let @t = join(fn, "\n")
        redir => out
        @t
        redir END
    finally
        let @t = t
    endtry
endf


" :nodoc:
" Define a syntax checker definition for a given filetype.
function! checksyntax#Alternative(filetype, alternative) "{{{3
    " TLogVAR a:filetype, a:alternative
    if has_key(g:checksyntax, a:filetype)
        if !has_key(g:checksyntax[a:filetype], 'alternatives')
            let odef = g:checksyntax[a:filetype]
            let g:checksyntax[a:filetype] = {'alternatives': [odef]}
            for key in s:top_level_fields
                if has_key(odef, key)
                    let g:checksyntax[a:filetype][key] = odef[key]
                endif
            endfor
        endif
        call add(g:checksyntax[a:filetype].alternatives, a:alternative)
    else
        let g:checksyntax[a:filetype] = a:alternative
    endif
endf


function! checksyntax#NullOutput(flag) "{{{3
    if empty(g:checksyntax#null)
        return ''
    else
        return a:flag .' '. g:checksyntax#null
    endif
endf


