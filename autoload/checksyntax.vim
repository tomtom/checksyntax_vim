" checksyntax.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-01-03.
" @Last Change: 2012-10-17.
" @Revision:    896


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
    "   auto* ... Run automatically when saving a file.
    "   efm  ... An 'errorformat' string.
    "   prepare ... An ex command that is run before doing anything.
    "   ignore_nr ... A list of error numbers that should be ignored.
    "   listtype ... Either loc (default) or qfl
    "   include ... Include another definition
    "   process_list ... Process a list of issues
    "   if ... An expression to test *once* whether a syntax checker 
    "            should be used.
    "   if_executable ... Test whether an application is executable.
    "   modified* ... If the buffer was modified, use an alternative 
    "            checker
    "   alternatives* ... A list of syntax checker definitions (the first 
    "            one with a valid executable is used. If used, no other 
    "            elements are allowed. This list is checked only once.
    "   run_alternatives* ... A string that defines how to run 
    "            alternatives (overrides |g:checksyntax#run_alternatives|).
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
    "   javascript   ... Syntax check; requires jslint, jshint, gjslint, or jsl
    "   lua          ... Requires luac
    "   php          ... Syntax check; requires php
    "   python       ... Requires pyflakes or pylint
    "   r            ... Requires lint::lint or svTools::lint
    "   ruby         ... Requires ruby
    "   tex, latex   ... Requires chktex
    "   viki         ... Requires deplate
    "   xhtml        ... Requires tidy
    "   xml, docbk   ... Requires xmllint
    "
    " Syntax checker definitions are kept in:
    " autoload/checksyntax/defs/{&filetype}.vim
    "
    " If |g:checksyntax#syntastic_dir| is set, syntastic's syntax 
    " checkers can be used too.
    " :read: let g:checksyntax = {...}   "{{{2
    let g:checksyntax = {}
endif


if !exists('g:checksyntax#syntastic_dir')
    " The directory where the syntastic plugin (see 
    " https://github.com/scrooloose/syntastic/) is installed.
    " If non-empty, use syntastic syntax checkers if available and if 
    " checksyntax does not have one defined for the current filetype.
    "
    " The syntastic directory does not have to be included in 
    " 'runtimepath'. Actually, using both, the syntastic and checksyntax 
    " plugin, simultaneously could cause conflicts.
    "
    " The value must not include a trailing (back)slash.
    " Optinally, the value may also point directly to the 
    " 'syntax_checkers' subdirectory.
    "
    " NOTE: Not all syntastic syntax checkers definitions are guaranteed 
    " to work with checksyntax.
    let g:checksyntax#syntastic_dir = ''   "{{{2
endif


if !exists('g:checksyntax#preferred')
    " A dictionary of 'filetype' => |regexp|.
    " If only one alternative should be run (see 
    " |g:checksyntax#run_alternatives|), check only those syntax 
    " checkers whose names matches |regexp|.
    let g:checksyntax#preferred = {'xml': '.'}   "{{{2
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
    let g:checksyntax#run_alternatives = 'first'   "{{{2
endif


if !exists('g:checksyntax#run_all_alternatives')
    " How to run "all" alternatives -- e.g., when calling the 
    " |:CheckSyntax| command with a bang.
    let g:checksyntax#run_all_alternatives = 'all' . (exists('g:loaded_asynccommand') ? ' async' : '')   "{{{2
endif


if !exists('g:checksyntax#async_runner')
    " Supported values:
    "   asynccommand ... Use the Asynccommand plugin
    let g:checksyntax#async_runner = exists('g:loaded_asynccommand') ? 'asynccommand' : ''  "{{{2
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

        elseif has_key(a:def, 'syntastic')

            " TLogVAR a:def
            try
                call call(a:def.syntastic, [])
                return 1
            catch /^Vim\%((\a\+)\)\=:E117/
                call remove(a:def, 'syntastic')
                echom "CheckSytnax: Syntastic not supported for this filetype. Please add" a:filetype "to g:checksyntax#syntastic#blacklist (and report to the author of checksyntax.vim)"
                call add(g:checksyntax#syntastic#blacklist, a:filetype)
            endtry

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
            if !has_key(g:checksyntax, a:filetype) || checksyntax#RunAlternativesMode(g:checksyntax[a:filetype]) !~? '\<first\>'
                if !empty(g:checksyntax#syntastic_dir)
                    call checksyntax#syntastic#Require(a:filetype)
                endif
            endif
        endif
        return has_key(g:checksyntax, a:filetype)
    endif
endf


" :nodoc:
function! s:Cmd(def) "{{{3
    if has_key(a:def, 'cmd')
        let cmd = matchstr(a:def.cmd, '^\(\\\s\|\S\+\|"\([^"]\|\\"\)\+"\)\+')
        let cmd = fnamemodify(cmd, ':t')
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
            let props = {
                        \ 'bg': bg,
                        \ 'bufnr': bufnr('%'),
                        \ 'filename': expand('%:p'),
                        \ 'manually': a:manually,
                        \ }
            let use_qfl = 0
            let all_issues = []
            let s:all_issues = []
            for [name, make_def] in items(defs.make_defs)
                " TLogVAR make_def
                let done = 0
                if async
                    let make_def1 = copy(make_def)
                    call extend(make_def1, props)
                    let make_def1.name = name
                    if g:checksyntax#async_runner == 'asynccommand'
                        let done = s:Run_asynccommand(make_def1)
                    else
                        throw 'Checksyntax: Unsupported value for g:checksyntax#async_runner: '. string(g:checksyntax#async_runner)
                    endif
                endif
                if !done
                    let use_qfl += s:Run_sync(all_issues, name, filetype, make_def)
                endif
            endfor
            " echom "DBG 1" string(list)
            if s:pending == 0
                if !empty(s:all_issues)
                    let all_issues += s:all_issues
                endif
                call s:HandleIssues(a:manually, use_qfl, bg, all_issues)
            else
                let s:all_issues += all_issues
            endif
        endif
    finally
        let s:run_alternatives_all = 0
    endtry
    redraw!
endf


function! s:GetDefsByFiletype(manually, filetype) "{{{3
    let defs = {'mode': '', 'make_defs': {}}
    call checksyntax#Require(a:filetype)
    let defs.mode = 'auto'
    let def = a:manually ? {} : s:GetDef(a:filetype .',auto')
    if empty(def)
        let def = s:GetDef(a:filetype)
    endif
    if &modified
        if has_key(def, 'modified')
            let defs.mode = 'auto'
            let def = s:GetDef(def.modified)
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
    for make_def in get(def, 'alternatives', [def])
        let name = checksyntax#Name(make_def)
        let defs.make_defs[name] = make_def
    endfor
    return defs
endf


function! s:HandleIssues(manually, use_qfl, bg, all_issues) "{{{3
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


let s:pending = 0
let s:all_issues = []

function! s:Run_asynccommand(make_def) "{{{3
    let cmd = ''
    if has_key(a:make_def, 'cmd')
        let cmd = get(a:make_def, 'cmd', '')
        let cmd .= ' '. shellescape(a:make_def.filename)
    elseif has_key(a:make_def, 'compiler')
        let compiler_def = s:WithCompiler(a:make_def.compiler,
                    \ 'return s:ExtractCompilerParams()',
                    \ {})
        " TLogVAR compiler_def
        if !empty(compiler_def)
            let cmd = compiler_def.cmd
            let a:make_def.efm = compiler_def.efm
        endif
    endif
    if !empty(cmd)
        let async_handler = s:AsyncCommandHandler(a:make_def)
        " TLogVAR cmd
        " TLogVAR async_handler
        let s:pending += 1
        call asynccommand#run(cmd, async_handler)
        return 1
    else
        echohl WarningMsg
        echom "CheckSyntax: Cannot run asynchronously: ". a:make_def.name
        echohl NONE
        return 0
    endif
endf


function! s:ExtractCompilerParams() "{{{3
    let cmd = &makeprg
    let replaced = []
    if stridx(cmd, '%') != -1
        let cmd = substitute(cmd, '\V%', escape(expand('%:p'), '\'), 'g')
        call add(replaced, '%')
    endif
    if stridx(cmd, '$*') != -1
        if index(replaced, '%') == -1
            let cmd = substitute(cmd, '\V$*', escape(expand('%:p'), '\'), 'g')
        else
            let cmd = substitute(cmd, '\V$*', '', 'g')
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


let s:async_handler = {}

function s:async_handler.get(temp_file_name) dict
    let s:pending -= 1
    " echom "DBG async_handler.get" s:pending self.name
    let errorformat = &errorformat
    try
        " TLogVAR self.async_type, self.bufnr, bufnr('%')
        if self.async_type != 'loc' || self.bufnr == bufnr('%')
            " let all_issues = g:checksyntax#prototypes[self.async_type].Get()
            " TLogVAR len(all_issues)
            let &errorformat = self.async_efm
            " TLogVAR self.async_efm
            " TLogVAR self.async_cmd, a.temp_file_name
            exe self.async_cmd a:temp_file_name
            let list = s:GetList(self.name, self, self.async_type)
            " TLogVAR list
            if g:checksyntax#debug
                echo
                echo printf('CheckSyntax: Processing %s (%s items)', self.name, len(list))
            endif
            " TLogVAR self.name, len(list)
            if !empty(list)
                let s:all_issues += list
                " echom "DBG async_handler.get all_issues:" len(all_issues)
                if s:pending == 0
                    " let bg = self.bg
                    let bg = 1
                    " let manually = self.manually
                    let manually = g:checksyntax#debug
                    let use_qfl = self.async_type == 'qfl'
                    " TLogVAR manually, bg, use_qfl
                    call s:HandleIssues(manually, use_qfl, bg, s:all_issues)
                endif
            endif
        endif
    finally
        let &errorformat = errorformat
    endtry
endf


function! s:AsyncCommandHandler(make_def)
    let type = get(a:make_def, 'listtype', 'loc')
    let async_handler = {
                \ 'async_cmd': type == 'loc' ? 'lgetfile' : 'cgetfile',
                \ 'async_type': type,
                \ 'async_efm': get(a:make_def, 'efm', &errorformat),
                \ }
    call extend(async_handler, a:make_def)
    call extend(async_handler, s:async_handler, 'keep')
    return asynccommand#tab_restore(async_handler)
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
        let list = s:GetList(a:name, def, type)
        if !empty(list)
            call extend(a:all_issues, list)
        endif
    endif
    return use_qfl
endf


function! s:GetList(name, def, type) "{{{3
    let list = g:checksyntax#prototypes[a:type].Get()
    " TLogVAR a:type, list
    " TLogVAR 1, len(list)
    if !empty(list)
        let list = filter(list, 's:FilterItem(a:def, v:val)')
        " TLogVAR 2, len(list)
        " TLogVAR a:type, list
        if !empty(list)
            let list = map(list, 's:CompleteItem(a:name, a:def, v:val)')
            if !empty(list)
                if has_key(a:def, 'process_list')
                    let list = call(a:def.process_list, [list])
                endif
                " TLogVAR 3, len(list)
                " TLogVAR a:type, list
                " TLogVAR a:type, list
            endif
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

