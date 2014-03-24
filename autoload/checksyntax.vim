" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    1438


if !exists('g:checksyntax#auto_enable_rx')
    " Enable automatic checking for filetypes matching this rx.
    " Set to "." to enable for all filetypes.
    " This requires |g:checksyntax_auto| to be > 0.
    " This variable overrules any filetype-specific settings in 
    " |g:checksyntax|.
    let g:checksyntax#auto_enable_rx = ''   "{{{2
endif


if !exists('g:checksyntax#auto_disable_rx')
    " Disable automatic checking for filetypes matching this rx.
    " Set to "." to disable for all filetypes.
    " This requires |g:checksyntax_auto| to be > 0.
    " This variable overrules any filetype-specific settings in 
    " |g:checksyntax|.
    let g:checksyntax#auto_disable_rx = ''   "{{{2
endif


if !exists('g:checksyntax#show_cmd')
    " A dictionary of VIM commands that are used to display the qf/loc 
    " lists.
    " If empty, do nothing.
    let g:checksyntax#show_cmd = {'qfl': 'copen', 'loc': 'lopen'}   "{{{2
endif


if !exists('g:checksyntax#lines_expr')
    " A vim expression that determines the number of lines of the 
    " qfl/loc window. If empty, don't set the size.
    " A useful value is: >
    "   let g:checksyntax#lines_expr = 'min([&previewheight, &lines / 2, len(getloclist(0))])'
    let g:checksyntax#lines_expr = ''   "{{{2
endif


if !exists('g:checksyntax#debug')
    let g:checksyntax#debug = 0
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
    "   asynccommand ... Use the AsyncCommand plugin
    let g:checksyntax#async_runner = has('clientserver') && !empty(v:servername) && exists(':AsyncMake') ? 'asynccommand' : ''  "{{{2
    if has('clientserver') && empty(v:servername)
        echohl WarningMsg
        echom "CheckSyntax: Run vim with the --servername NAME command line option to enable use of AsyncCommand"
        echohl NONE
    endif
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
    let g:checksyntax#null = g:checksyntax#windows ? 'NUL' : (filereadable('/dev/null') ? '/dev/null' : '')    "{{{2
endif


if !exists('g:checksyntax#cygwin_path_rx')
    " If a full windows filename (with slashes instead of backslashes) 
    " matches this |regexp|, it is assumed to be a cygwin executable.
    let g:checksyntax#cygwin_path_rx = '/cygwin/'   "{{{2
endif


if !exists('g:checksyntax#cygwin_expr')
    " For cygwin binaries, convert command calls using this vim 
    " expression.
    let g:checksyntax#cygwin_expr = '"bash -c ''". escape(%s, "''\\") ."''"'   "{{{2
endif


let s:cygwin = {}

function! s:CygwinBin(cmd) "{{{3
    " TLogVAR a:cmd
    if !g:checksyntax#windows
        return 0
    elseif has_key(s:cygwin, a:cmd)
        let rv = s:cygwin[a:cmd]
    else
        if !s:Executable('cygpath', 1) || !s:Executable('which', 1)
            let rv = 0
        else
            let which = substitute(system('which '. shellescape(a:cmd)), '\n$', '', '')
            " echom "DBG which:" which
            if which =~ '^/'
                let filename = system('cygpath -ma '. shellescape(which))
                " echom "DBG filename:" filename
                let rv = filename =~ g:checksyntax#cygwin_path_rx
            else
                let rv = 0
            endif
        endif
        let s:cygwin[a:cmd] = rv
    endif
    " TLogVAR rv
    return rv
endf


let s:executables = {}

function! s:Executable(cmd, ...) "{{{3
    " TLogVAR a:cmd
    " echom "DBG has_key(s:executables, a:cmd)" has_key(s:executables, a:cmd)
    if !has_key(s:executables, a:cmd)
        let executable = executable(a:cmd)
        " TLogVAR 1, executable
        let ignore_cyg = a:0 >= 1 ? a:1 : !g:checksyntax#windows
        if !executable && !ignore_cyg
            let executable = s:CygwinBin(a:cmd)
            " TLogVAR 2, executable
        endif
        let s:executables[a:cmd] = executable
    endif
    " echom "DBG s:executables[a:cmd]" s:executables[a:cmd]
    return s:executables[a:cmd]
endf


if !exists('g:checksyntax#check_cygpath')
    " If true, check whether we have to convert a path via cyppath -- 
    " see |checksyntax#MaybeUseCygpath|
    let g:checksyntax#check_cygpath = g:checksyntax#windows && s:Executable('cygpath')   "{{{2
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

    
function! s:Open(bg, type) "{{{3
    " TLogVAR a:bg
    let cmd = get(g:checksyntax#show_cmd, a:type, '')
    if !empty(cmd)
        if empty(g:checksyntax#lines_expr) || !empty(lines)
            let bufnr = bufnr('%')
            let winnr = winnr()
            exec cmd
            if a:bg && bufnr != bufnr('%')
                if !empty(g:checksyntax#lines_expr)
                    let lines = eval(g:checksyntax#lines_expr)
                    " TLogVAR lines
                    exec 'resize' lines
                endif
                wincmd p
            endif
        endif
    endif
endf


if empty(g:checksyntax#prototypes.loc)
    function! g:checksyntax#prototypes.loc.Close() dict "{{{3
        lclose
    endf

    function! g:checksyntax#prototypes.loc.Open(bg) dict "{{{3
        call s:Open(a:bg, 'loc')
    endf

    function! g:checksyntax#prototypes.loc.GetExpr(args) dict "{{{3
        " TLogDBG system(a:args)
        return s:RunCmd('lgetexpr', 'system('. string(a:args). ')')
    endf

    function! g:checksyntax#prototypes.loc.Make(args) dict "{{{3
        return s:RunCmd('lmake!', a:args)
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
        call s:Open(a:bg, 'qfl')
    endf

    function! g:checksyntax#prototypes.qfl.GetExpr(args) dict "{{{3
        " TLogDBG system(a:args)
        return s:RunCmd('cgetexpr', 'system('. string(a:args). ')')
    endf

    function! g:checksyntax#prototypes.qfl.Make(args) dict "{{{3
        return s:RunCmd('make!', a:args)
    endf

    function! g:checksyntax#prototypes.qfl.Get() dict "{{{3
        return copy(getqflist())
    endf

    function! g:checksyntax#prototypes.qfl.Set(list) dict "{{{3
        call setqflist(a:list)
    endf
endif


function! s:RunCmd(cmd, args) "{{{3
    try
        " TLogVAR a:cmd, a:args, &efm
        exec 'silent' a:cmd a:args
        return 1
    catch
        echohl Error
        echom v:exception
        echohl NONE
        return 0
    endtry
endf


let s:checkers = {}
let s:top_level_fields = ['modified', 'auto', 'run_alternatives', 'alternatives']
let s:mandatory = ['cmd', 'cmdexpr', 'compiler', 'exec']


" Define a syntax checker definition for a given filetype.
" If filetype ends with "?", add only if no checker with the given name 
" is defined.
"
" A checker definition is a dictionary with the following fields:
" 
" Mandatory (either one of the following):
"
"   cmd ........ A shell command used as 'makeprg' to check the file.
"   cmdexpr .... A vim expression that returns the cmd
"   compiler ... A vim compiler that is used to check the file.
"   exec ....... A vim command used to check the file (deprecated; use 
"                cmdexpr & process_list instead)
" 
" Optional:
"
"   efm  ....... An 'errorformat' string.
"   prepare .... An ex command that is run before doing anything.
"   ignore_nr .. A list of error numbers that should be ignored.
"   listtype ... Either loc (default) or qfl
"   include .... Include another definition
"   process_list .. Process a list of issues
"   if ......... An expression to test *once* whether a syntax checker 
"                should be used.
"   if_executable .. Test whether an application is executable.
"   buffers .... Keep results only for either "current", "listed", or 
"                "all" buffers
"   compiler_args .. Internal use
"   cmd_args ... Internal use
"
" Optional top-level fields:
"
"   auto ....... Run automatically when saving a file (see also 
"                |g:checksyntax#auto_enable_rx| and 
"                |g:checksyntax#auto_disable_rx|)
"   modified ... The name of a pseudo-filetype that should be used if 
"                the buffer was modified
"   run_alternatives ... A string that defines how to run 
"                alternatives (overrides 
"                |g:checksyntax#run_alternatives|).
"
" Top-level fields affect how syntax checkers for a filetype are run.
function! checksyntax#AddChecker(filetype, ...) "{{{3
    if a:0 == 1 && type(a:1) == 3
        let alternatives = a:1
    else
        let alternatives = a:000
    endif
    " TLogVAR alternatives
    if !empty(alternatives)
        let [update, filetype] = s:UpName(a:filetype)
        " TLogVAR filetype, update, a:000, a:0, type(a:1)
        if !has_key(s:checkers, filetype)
            let s:checkers[filetype] = {'alternatives': {}, 'order': []}
        endif
        for make_def in alternatives
            " Copy top_level_fields
            for upkey in s:top_level_fields
                let [kupdate, key] = s:UpName(upkey)
                if has_key(make_def, key) && (kupdate || !has_key(s:checkers[filetype], key))
                    let s:checkers[filetype][key] = remove(make_def, key)
                endif
            endfor
            " If there are other fields, add make_def
            if !empty(make_def)
                if has_key(make_def, 'cmdexpr')
                    let make_def.cmd = eval(make_def.cmdexpr)
                endif
                " TLogVAR make_def
                if !has_key(make_def, 'cmd') || !empty(make_def.cmd)
                    let [update_name, name] = s:UpNameFromDef(make_def)
                    if empty(name)
                        throw "CheckSyntax: Name must not be empty: ". filetype .': '. string(make_def)
                    elseif empty(filter(copy(s:mandatory), 'has_key(make_def, v:val)'))
                        throw "CheckSyntax: One of ". join(s:mandatory, ', ') ." must be defined: ". filetype .': '. string(make_def)
                    else
                        let new_item = !has_key(s:checkers[filetype].alternatives, name)
                        if update || update_name || new_item
                            let s:checkers[filetype].alternatives[name] = make_def
                            if new_item
                                call add(s:checkers[filetype].order, name)
                            endif
                        endif
                    endif
                endif
            endif
        endfor
    endif
endf


function! checksyntax#GetChecker(filetype, ...) "{{{3
    call checksyntax#Require(a:filetype)
    let alts = get(get(s:checkers, a:filetype, {}), 'alternatives', {})
    if a:0 == 0
        return values(alts)
    else
        return values(filter(copy(alts), 'index(a:000, v:key) != -1'))
    endif
endf


" :nodoc:
" Run |:make| based on a syntax checker definition.
function! s:RunSyncWithEFM(make_def) "{{{3
    " TLogVAR a:make_def
    let type = get(a:make_def, 'listtype', 'loc')
    let shellpipe = &shellpipe
    let errorformat = &errorformat
    if has_key(a:make_def, 'shellpipe')
        let &shellpipe = get(a:make_def, 'shellpipe')
        " TLogVAR &shellpipe
    endif
    if has_key(a:make_def, 'efm')
        let &errorformat = get(a:make_def, 'efm')
        " TLogVAR &errorformat
    endif
    try
        if has_key(a:make_def, 'cmd')
            let cmddef = s:ExtractCompilerParams(a:make_def, '%', a:make_def.cmd)
            let cmd = s:NativeCmd(cmddef.cmd)
            " TLogVAR cmd
            let rv = g:checksyntax#prototypes[type].GetExpr(cmd)
            " TLogVAR rv, getqflist()
            return rv
        elseif has_key(a:make_def, 'exec')
            exec a:make_def.exec
            return 1
        endif
    finally
        if &shellpipe != shellpipe
            let &shellpipe = shellpipe
        endif
        if &errorformat != errorformat
            let &errorformat = errorformat
        endif
    endtry
endf


let s:convert_filenames = {}

function! s:ConvertFilenames(make_def, props) "{{{3
    for key in ['filename', 'altname']
        let filename = a:props[key]
        let convert_filename = get(a:make_def, 'convert_filename', '')
        if !empty(convert_filename)
            if !has_key(s:convert_filenames, convert_filename)
                let s:convert_filenames[convert_filename] = {}
            endif
            if has_key(s:convert_filenames[convert_filename], filename)
                let filename = s:convert_filenames[convert_filename][filename]
            else
                " TLogVAR filename, convert_filename
                let cmd = printf(convert_filename, shellescape(filename))
                " TLogVAR cmd
                let filename = system(cmd)
                let filename = substitute(filename, '\n$', '', '')
                let s:convert_filenames[convert_filename][filename] = filename
            endif
            " TLogVAR filename
        endif
        let a:make_def[key] = filename
    endfor
    return a:make_def
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
        return has_key(s:checkers, a:filetype)
    endif
endf


function! s:NativeCmd(cmd) "{{{3
    if !empty(g:checksyntax#cygwin_expr) && s:CygwinBin(matchstr(a:cmd, '^\S\+'))
        let cmd = eval(printf(g:checksyntax#cygwin_expr, string(a:cmd)))
        " TLogVAR cmd
        return cmd
    else
        return a:cmd
    endif
endf


" :nodoc:
function! s:Cmd(make_def) "{{{3
    if has_key(a:make_def, 'cmd')
        let cmd = matchstr(a:make_def.cmd, '^\(\\\s\|\S\+\|"\([^"]\|\\"\)\+"\)\+')
    else
        let cmd = ''
    endif
    return cmd
endf


" :nodoc:
function! s:UpName(upname) "{{{3
    if a:upname =~ '?$'
        let update = 0
        let name = substitute(a:upname, '?$', '', '')
    else
        let update = 1
        let name = a:upname
    endif
    return [update, name]
endf


" :nodoc:
function! s:UpNameFromDef(make_def) "{{{3
    let name = get(a:make_def, 'name', '')
    if empty(name)
        let name = get(a:make_def, 'compiler', '')
    endif
    if empty(name)
        let name = s:Cmd(a:make_def)
    endif
    return s:UpName(name)
endf


function! s:ValidAlternative(make_def) "{{{3
    " TLogVAR a:make_def
    if has_key(a:make_def, 'if')
        return eval(a:make_def.if)
    elseif has_key(a:make_def, 'if_executable')
        return s:Executable(a:make_def.if_executable)
    else
        return 1
    endif
endf


function! s:GetValidAlternatives(filetype, run_alternatives, alternatives) "{{{3
    " TLogVAR a:filetype, a:run_alternatives, a:alternatives
    let valid = {}
    for name in get(get(s:checkers, a:filetype, {}), 'order', [])
        let alternative = a:alternatives[name]
        " TLogVAR alternative
        if s:ValidAlternative(alternative)
            if has_key(alternative, 'cmd')
                let cmd = s:Cmd(alternative)
                " TLogVAR cmd
                if !empty(cmd) && !s:Executable(cmd)
                    continue
                endif
            endif
            let valid[name] = alternative
            if a:run_alternatives =~? '\<first\>'
                break
            endif
        endif
    endfor
    return valid
endf


let s:run_alternatives_all = 0

" :nodoc:
function! checksyntax#RunAlternativesMode(make_def) "{{{3
    let rv = s:run_alternatives_all ? g:checksyntax#run_all_alternatives : get(a:make_def, 'run_alternatives', g:checksyntax#run_alternatives)
    " TLogVAR a:make_def, rv
    return rv
endf


function! s:GetDef(filetype) "{{{3
    " TLogVAR a:filetype
    if has_key(s:checkers, a:filetype)
        let dict = s:checkers
        let rv = s:checkers[a:filetype]
    else
        let dict = {}
        let rv = {}
    endif
    if !empty(dict)
        let alternatives = get(rv, 'alternatives', {})
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


let s:async_pending = {}


let g:checksyntax#issues = {}


function! g:checksyntax#issues.Reset() dict "{{{3
    let self.issues = []
    let self.type = 'loc'
endf

call g:checksyntax#issues.Reset()


function! g:checksyntax#issues.AddList(name, make_def, type) dict "{{{3
    if a:type == 'qfl'
        let self.type = a:type
    endif
    let issues = checksyntax#GetList(a:name, a:make_def, a:type)
    if !empty(issues)
        let self.issues += issues
    endif
    return issues
endf


function! g:checksyntax#issues.Display(manually, bg) dict "{{{3
    if empty(self.issues)
        call g:checksyntax#prototypes[self.type].Set(self.issues)
        call CheckSyntaxSucceed(self.type, a:manually)
    else
        " TLogVAR self.issues
        call sort(self.issues, 's:CompareIssues')
        " TLogVAR self.issues
        " TLogVAR self.type
        call g:checksyntax#prototypes[self.type].Set(self.issues)
        " TLogVAR self.type, a:manually, a:bg
        call CheckSyntaxFail(self.type, a:manually, a:bg)
    endif
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
    let wd = getcwd()
    let bd = expand('%:p:h')
    let will_display = 0
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
                let defs.make_defs = filter(defs.make_defs, 's:UpNameFromDef(v:val)[1] =~ preferred_rx')
            endif
            let async = !empty(g:checksyntax#async_runner) && defs.run_alternatives =~? '\<async\>'
            " TLogVAR async
            if !empty(s:async_pending)
                if !a:manually && async
                    echohl WarningMsg
                    echo "CheckSyntax: Still waiting for async results ..."
                    echohl NONE
                    return
                else
                    let s:async_pending = {}
                endif
            endif
            let props = {
                        \ 'bg': bg,
                        \ 'bufnr': bufnr('%'),
                        \ 'filename': expand('%'),
                        \ 'altname': expand('#'),
                        \ 'manually': a:manually,
                        \ }
            call g:checksyntax#issues.Reset()
            for [name, make_def] in items(defs.make_defs)
                " TLogVAR make_def
                let make_def1 = copy(make_def)
                let done = 0
                if async
                    call extend(make_def1, props)
                    let make_def1 = s:ConvertFilenames(make_def1, make_def1)
                    let make_def1.name = name
                    let make_def1.job_id = name .'_'. make_def1.bufnr
                    let done = s:Run_async(make_def1)
                endif
                if !done
                    let make_def1 = s:ConvertFilenames(make_def1, props)
                    let done = s:Run_sync(name, filetype, make_def1)
                endif
            endfor
            " echom "DBG 1" string(list)
            if empty(s:async_pending)
                let will_display = 1
            endif
        endif
    finally
        let s:run_alternatives_all = 0
        if will_display
            call g:checksyntax#issues.Display(a:manually, bg)
        endif
    endtry
    redraw!
endf


function! s:Status() "{{{3
    if empty(s:async_pending)
        echo "CheckSyntax: No pending jobs"
    else
        echo "CheckSyntax: Pending jobs:"
        for [job_id, make_def] in items(s:async_pending)
            echo printf("  %s: bufnr=%s, cmd=%s",
                        \ job_id,
                        \ make_def.bufnr, 
                        \ make_def.name
                        \ )
        endfor
    endif
endf


function! s:GetDefsByFiletype(manually, filetype) "{{{3
    " TLogVAR a:manually, a:filetype
    let defs = {'mode': '', 'make_defs': {}}
    call checksyntax#Require(a:filetype)
    " let defs.mode = 'auto'
    let make_def = a:manually ? {} : s:GetDef(a:filetype .',auto')
    " TLogVAR 1, make_def
    if empty(make_def)
        let make_def = s:GetDef(a:filetype)
        " TLogVAR 2, make_def
    endif
    if &modified
        if has_key(make_def, 'modified')
            let make_def = s:GetDef(make_def.modified)
            " TLogVAR 3, make_def
        else
            echohl WarningMsg
            echom "Buffer was modified. Please save it before calling :CheckSyntax."
            echohl NONE
            return
        endif
    endif
    " TLogVAR make_def
    if empty(make_def)
        return defs
    endif
    if v:dying
        let auto = 0
    elseif !empty(g:checksyntax#auto_enable_rx) && a:filetype =~ g:checksyntax#auto_enable_rx
        let auto = 1
    elseif !empty(g:checksyntax#auto_disable_rx) && a:filetype =~ g:checksyntax#auto_disable_rx
        let auto = 0
    else
        let auto = get(make_def, 'auto', 0)
    endif
    " TLogVAR auto
    if !(a:manually || auto)
        return defs
    endif
    let defs.run_alternatives = checksyntax#RunAlternativesMode(make_def)
    " TLogVAR &makeprg, &l:makeprg, &g:makeprg, &errorformat
    " TLogVAR make_def
    let defs.make_defs = get(make_def, 'alternatives', {'*': make_def})
    " TLogVAR defs
    return defs
endf


function! s:CompareIssues(i1, i2) "{{{3
    let l1 = get(a:i1, 'lnum', 0)
    let l2 = get(a:i2, 'lnum', 0)
    " TLogVAR l1, l2, type(l1), type(l2)
    return l1 == l2 ? 0 : l1 > l2 ? 1 : -1
endf


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


function! s:RunSyncChecker(filetype, make_def)
    let bufnr = bufnr('%')
    let pos = getpos('.')
    let type = get(a:make_def, 'listtype', 'loc')
    try
        if has_key(a:make_def, 'compiler')
            " <+TODO+> Use s:ExtractCompilerParams and run s:RunSyncWithEFM
            let args = get(a:make_def, 'compiler_args', '%')
            let rv = s:WithCompiler(a:make_def.compiler,
                        \ 'call g:checksyntax#prototypes[type].Make('. string(args) .')',
                        \ 1)
        else
            let rv = s:RunSyncWithEFM(a:make_def)
        endif
        " TLogVAR rv
        return rv
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


function! s:Run_async(make_def) "{{{3
    " TLogVAR a:make_def
    let make_def = a:make_def
    let cmd = ''
    if has_key(make_def, 'cmd')
        let cmd = get(make_def, 'cmd', '')
        " let cmd .= ' '. shellescape(make_def.filename)
        if has_key(a:make_def, 'cmd_args')
            let cmddef = s:ExtractCompilerParams(a:make_def, '', a:make_def.cmd)
            let cmd = cmddef.cmd
        else
            let cmd .= ' '. escape(make_def.filename, '"''\ ')
        endif
    elseif has_key(make_def, 'compiler')
        let compiler_def = s:WithCompiler(make_def.compiler,
                    \ 'return s:ExtractCompilerParams('. string(a:make_def) .', "")',
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
            let cmd = s:NativeCmd(cmd)
            " TLogVAR cmd
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


function! s:ReplaceMakeArgs(make_def, cmd, args) "{{{3
    let cmd = a:cmd
    if !empty(a:args) && stridx(cmd, '$*') == -1
        let cmd .= ' '. a:args
    endif
    let replaced = []
    if stridx(cmd, '%') != -1
        let cmd = substitute(cmd, '%\(\%(:[phtre]\)\+\)\?', '\=s:Filename(a:make_def, "%", submatch(1))', 'g')
        call add(replaced, '%')
    endif
    if stridx(cmd, '$*') != -1
        if index(replaced, '%') == -1
            let cmd = substitute(cmd, '\V$*', a:args .' '. escape(a:make_def['filename'], '\'), 'g')
            call add(replaced, '%')
        else
            let cmd = substitute(cmd, '\V$*', a:args, 'g')
        endif
        call add(replaced, '$*')
    endif
    if stridx(cmd, '#') != -1
        let cmd = substitute(cmd, '#\(\%(:[phtre]\)\+\)\?', '\=s:Filename(a:make_def, "#", submatch(1))', 'g')
        call add(replaced, '#')
    endif
    return cmd
endf


function! s:Filename(make_def, type, mod) "{{{3
    if a:type == '%'
        let filename = a:make_def.filename
    elseif a:type == '#'
        let filename = a:make_def.altname
    else
        throw "CheckSyntax/s:Filename: Internal error: type = ". a:type
    endif
    if !empty(a:mod)
        let filename = fnamemodify(filename, a:mod)
    endif
    return escape(filename, '\')
endf


function! s:ExtractCompilerParams(make_def, args, ...) "{{{3
    let cmd = a:0 >= 1 ? a:1 : &makeprg
    let args = get(a:make_def, 'compiler_args', a:args)
    let cmd = s:ReplaceMakeArgs(a:make_def, cmd, args)
    let compiler_def = {
                \ 'cmd': cmd,
                \ 'efm': &errorformat
                \ }
    " TLogVAR compiler_def
    return compiler_def
endf


let s:status_expr = 'checksyntax#Status()'

function! checksyntax#AddJob(make_def) "{{{3
    let s:async_pending[a:make_def.job_id] = a:make_def
    if exists('g:tstatus_exprs')
        if index(g:tstatus_exprs, s:status_expr) == -1
            call add(g:tstatus_exprs, s:status_expr)
        endif
    endif
endf


function! checksyntax#RemoveJob(job_id) "{{{3
    let rv = has_key(s:async_pending, a:job_id)
    if rv
        call remove(s:async_pending, a:job_id)
        if empty(s:async_pending) && exists('g:tstatus_exprs')
            let idx = index(g:tstatus_exprs, s:status_expr)
            if idx != -1
                call remove(g:tstatus_exprs, idx)
            endif
        endif
    endif
    return rv ? len(s:async_pending) : -1
endf


function! checksyntax#Status() "{{{3
    let n = len(s:async_pending)
    if n == 0
        return ''
    else
        return 'PendingChecks='. n
    endif
endf


function! s:Run_sync(name, filetype, make_def) "{{{3
    " TLogVAR a:name, a:filetype, a:make_def
    let make_def = a:make_def
    if has_key(make_def, 'include')
        let include = s:GetDef(make_def.include)
        if !empty(include)
            let make_def = extend(copy(make_def), include, 'keep')
        endif
    endif
    exec get(make_def, 'prepare', '')
    if s:RunSyncChecker(a:filetype, make_def)
        let type = get(make_def, 'listtype', 'loc')
        call g:checksyntax#issues.AddList(a:name, make_def, type)
        return 1
    else
        return 0
    endif
endf


function! checksyntax#GetList(name, make_def, type) "{{{3
    " TLogVAR a:type
    let list = g:checksyntax#prototypes[a:type].Get()
    " TLogVAR list
    " TLogVAR 1, len(list), has_key(a:make_def, 'process_list')
    if !empty(list) && has_key(a:make_def, 'process_list')
        " TLogVAR a:make_def.process_list
        let list = call(a:make_def.process_list, [list])
        " TLogVAR 2, len(list)
    endif
    if !empty(list)
        let list = filter(list, 's:FilterItem(a:make_def, v:val)')
        " TLogVAR 3, len(list)
        " TLogVAR a:type, list
        if !empty(list)
            let list = map(list, 's:CompleteItem(a:name, a:make_def, v:val)')
            " TLogVAR 4, len(list)
            " TLogVAR a:type, list
        endif
    endif
    " TLogVAR "return", list
    return list
endf


function! s:CompleteItem(name, make_def, val) "{{{3
    " TLogVAR a:name, a:make_def, a:val
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


function! s:FilterItem(make_def, val) "{{{3
    if a:val.lnum == 0 && a:val.pattern == ''
        return 0
    elseif has_key(a:val, 'nr') && has_key(a:make_def, 'ignore_nr') && index(a:make_def.ignore_nr, a:val.nr) != -1
        return 0
    elseif has_key(a:make_def, 'buffers')
        let buffers = a:make_def.buffers
        if buffers == 'listed' && !buflisted(a:val.bufnr)
            return 0
        elseif buffers == 'current' && a:val.bufnr != a:make_def.bufnr
            return 0
        endif
    endif
    return 1
endf


function! checksyntax#NullOutput(flag) "{{{3
    if empty(g:checksyntax#null)
        return ''
    else
        return a:flag .' '. g:checksyntax#null
    endif
endf


" If cmd seems to be a cygwin executable, use cygpath to convert 
" filenames. This assumes that cygwin's which command returns full 
" filenames for non-cygwin executables.
function! checksyntax#MaybeUseCygpath(cmd) "{{{3
    " echom "DBG" a:cmd
    if g:checksyntax#check_cygpath && s:CygwinBin(a:cmd)
        return 'cygpath -u %s'
    endif
    return ''
endf


function! checksyntax#SetupSyntax(syntax) "{{{3
    let after_syntax = []
    if index(g:checksyntax_enable_syntax, a:syntax) != -1
        call add(after_syntax, a:syntax)
    endif
    if exists('b:checksyntax_enable_syntax')
        let after_syntax += b:checksyntax_enable_syntax
    endif
    " TLogVAR after_syntax
    redir => hidef
    silent! hi CheckSyntaxError
    redir END
    if hidef !~ '\<guisp\>'
        let fg = &bg == 'dark' ? 'yellow' : 'brown'
        exec 'hi CheckSyntaxError term=standout cterm=underline ctermfg=red gui=undercurl guisp=red guifg='. fg
        exec 'hi CheckSyntaxWarning term=standout cterm=underline ctermfg=cyan gui=undercurl guisp=cyan guifg='. fg
    endif
    for asyn in after_syntax
        exec 'runtime! autoload/checksyntax/syntax/'. asyn .'.vim'
    endfor
endf

