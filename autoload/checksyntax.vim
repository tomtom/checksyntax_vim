" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    1671

if exists(':Tlibtrace') != 2
    command! -nargs=+ -bang Tlibtrace :
endif


if !exists('g:checksyntax#auto_filetypes')
    " Enable automatic checking for these filetypes.
    let g:checksyntax#auto_filetypes = []   "{{{2
endif

if !exists('g:checksyntax#auto_enable_rx')
    " Enable automatic checking for filetypes matching this rx.
    " Set to "." to enable for all filetypes.
    " This requires |g:checksyntax_auto| to be > 0.
    " This variable overrules any filetype-specific settings in 
    " |g:checksyntax|.
    let g:checksyntax#auto_enable_rx = empty(g:checksyntax#auto_filetypes) ? '' : printf('\(%s\)', join(g:checksyntax#auto_filetypes, '\|'))   "{{{2
endif


if !exists('g:checksyntax#auto_disable_rx')
    " Disable automatic checking for filetypes matching this rx.
    " Set to "." to disable for all filetypes.
    " This requires |g:checksyntax_auto| to be > 0.
    " This variable overrules any filetype-specific settings in 
    " |g:checksyntax|.
    let g:checksyntax#auto_disable_rx = ''   "{{{2
endif


if !exists('g:checksyntax#enable_syntax')
    " A list of filetypes for which frequent beginner errors will be 
    " highlighted by matching lines against |regexp|s defined in the 
    " file `autoload/checksyntax/syntax/{FILETYPE}.vim`.
    "
    " See :echo globpath(&rtp, 'autoload/checksyntax/syntax/*.vim') for 
    " supported filetypes/checks.
    "
    " The variable can also be buffer-local. In this case all named 
    " types will be loaded.
    "
    "                                                   *b:checksyntax_enable_syntax*
    " E.g. in order to enable highlighting trailing whitespace, use: >
    "
    "   let b:checksyntax_enable_syntax = ['trailing_whitespace']
    "
    " If you want to enable this for all file of filetype X, add this 
    " line to in `after/syntax/X.vim` or use
    "
    "   let g:checksyntax#enable_syntax_X = ['trailing_whitespace']
    let g:checksyntax#enable_syntax = []   "{{{2
endif


if !exists('g:checksyntax#enable_syntax_')
    " A list of syntax checks (see |g:checksyntax#enable_syntax|) that 
    " should be enabled by default.
    let g:checksyntax#enable_syntax_ = []   "{{{2
endif


if !exists('g:checksyntax#list_height')
    let g:checksyntax#list_height = 4   "{{{2
endif


if !exists('g:checksyntax#show_cmd')
    " A dictionary of VIM commands that are used to display the qf/loc 
    " lists.
    " If empty, do nothing.
    let g:checksyntax#show_cmd = {'qfl': 'copen '. g:checksyntax#list_height, 'loc': 'lopen '. g:checksyntax#list_height}   "{{{2
endif


if !exists('g:checksyntax#lines_expr')
    " A vim expression that determines the number of lines of the 
    " qfl/loc window. If empty, don't set the size.
    " A useful value is: >
    "   let g:checksyntax#lines_expr = 'min([&previewheight, &lines / 2, len(getloclist(0))])'
    let g:checksyntax#lines_expr = ''   "{{{2
endif


if !exists('g:checksyntax#background')
    " If true, the current window will keep the focus when displaying 
    " the issues list.
    let g:checksyntax#background = 1   "{{{2
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
    if exists('*job_start')
        let g:checksyntax#async_runner = 'vim8'
    elseif !has('clientserver')
        let g:checksyntax#async_runner = ''
    elseif empty(v:servername)
        echohl WarningMsg
        echom 'CheckSyntax: Run vim with the --servername NAME command line option to enable use of AsyncCommand'
        echohl NONE
        let g:checksyntax#async_runner = ''
    else
        " Supported values:
        "   asynccommand ... Use the AsyncCommand plugin
        let g:checksyntax#async_runner = exists(':AsyncMake') ? 'asynccommand' : ''  "{{{2
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
    let g:checksyntax#windows = &shell !~# 'sh' && (has('win16') || has('win32') || has('win64'))   "{{{2
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

function! s:CygwinBin(cmd) abort "{{{3
    Tlibtrace 'checksyntax', a:cmd
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
            if which =~# '^/'
                let filename = system('cygpath -ma '. shellescape(which))
                " echom "DBG filename:" filename
                let rv = filename =~ g:checksyntax#cygwin_path_rx
            else
                let rv = 0
            endif
        endif
        let s:cygwin[a:cmd] = rv
    endif
    Tlibtrace 'checksyntax', rv
    return rv
endf


let s:executables = {}

function! s:Executable(cmd, ...) abort "{{{3
    Tlibtrace 'checksyntax', a:cmd
    " echom "DBG has_key(s:executables, a:cmd)" has_key(s:executables, a:cmd)
    if !has_key(s:executables, a:cmd)
        let executable = executable(a:cmd)
        Tlibtrace 'checksyntax', 1, executable
        let ignore_cyg = a:0 >= 1 ? a:1 : !g:checksyntax#windows
        if !executable && !ignore_cyg
            let executable = s:CygwinBin(a:cmd)
            Tlibtrace 'checksyntax', 2, executable
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
    function! CheckSyntaxSucceed(type, manually) abort dict
        call s:prototypes[a:type].Close()
        if a:manually
            echo
            echo 'Syntax ok.'
        endif
    endf
endif


if !exists('*CheckSyntaxFail')
    " This function is called when a syntax error was found.
    function! CheckSyntaxFail(type, manually, bg) abort dict
        Tlibtrace 'checksyntax', a:type, a:manually, a:bg
        call s:prototypes[a:type].Open(a:bg)
    endf
endif


if !exists('s:prototypes')
    " Contains prototype definitions for syntax checkers that use the 
    " |location-list| ("loc") or the |quixfix|-list.
    let s:prototypes = {'loc': {}, 'qfl': {}} "{{{2
endif


function! s:Open(bg, type, obj) abort "{{{3
    let cmd = get(g:checksyntax#show_cmd, a:type, '')
    Tlibtrace 'checksyntax', a:bg, a:type, cmd
    if !empty(cmd)
        let bufnr = bufnr('%')
        let winnr = winnr()
        Tlibtrace 'checksyntax', bufnr, winnr
        try
            exec cmd
        finally
            Tlibtrace 'checksyntax', bufnr('%')
            if a:bg && bufnr != bufnr('%')
                if !empty(g:checksyntax#lines_expr)
                    let lines = eval(g:checksyntax#lines_expr)
                    if lines > 0
                        Tlibtrace 'checksyntax', lines
                        exec 'resize' lines
                        redraw!
                    endif
                endif
                wincmd p
            endif
        endtry
    endif
endf


if empty(s:prototypes.loc)
    function! s:prototypes.loc.Close() abort dict "{{{3
        lclose
    endf

    function! s:prototypes.loc.Open(bg) abort dict "{{{3
        call s:Open(a:bg, 'loc', self)
    endf

    function! s:prototypes.loc.GetExpr(args) abort dict "{{{3
        " TLogDBG system(a:args)
        return s:RunCmd('lgetexpr', 'system('. string(a:args). ')')
    endf

    function! s:prototypes.loc.Make(args) abort dict "{{{3
        return s:RunCmd('lmake!', a:args)
    endf

    function! s:prototypes.loc.Get() abort dict "{{{3
        return copy(getloclist(0))
    endf

    function! s:prototypes.loc.Set(list) abort dict "{{{3
        call setloclist(0, a:list)
    endf
endif


if empty(s:prototypes.qfl)
    function! s:prototypes.qfl.Close() abort dict "{{{3
        cclose
    endf

    function! s:prototypes.qfl.Open(bg) abort dict "{{{3
        call s:Open(a:bg, 'qfl', self)
    endf

    function! s:prototypes.qfl.GetExpr(args) abort dict "{{{3
        " TLogDBG system(a:args)
        return s:RunCmd('cgetexpr', 'system('. string(a:args). ')')
    endf

    function! s:prototypes.qfl.Make(args) abort dict "{{{3
        return s:RunCmd('make!', a:args)
    endf

    function! s:prototypes.qfl.Get() abort dict "{{{3
        return copy(getqflist())
    endf

    function! s:prototypes.qfl.Set(list) abort dict "{{{3
        call setqflist(a:list)
    endf
endif


function! s:RunCmd(cmd, args) abort "{{{3
    try
        Tlibtrace 'checksyntax', a:cmd, a:args, &efm
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
let s:mandatory = ['cmd', 'cmdexpr', 'checkergen', 'compiler', 'exec']


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
"   checkergen . A vim function, which takes its definition as argument 
"                and returns a dictionary of {NAME => CHECKER}
"   compiler ... A vim compiler that is used to check the file.
"   exec ....... A vim command used to check the file (deprecated; use 
"                cmdexpr & process_list instead)
" 
" Optional:
"
"   efm  ....... An 'errorformat' string.
"   prepare .... An ex command that is run before doing anything.
"   ignore_nr .. A list of error numbers that should be ignored.
"   ignore_rx .. A regexp of messages that should be ignored.
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
function! checksyntax#AddChecker(filetype, ...) abort "{{{3
    if a:0 == 1 && type(a:1) == 3
        let alternatives = a:1
    else
        let alternatives = a:000
    endif
    Tlibtrace 'checksyntax', alternatives
    if !empty(alternatives)
        let [update, filetype] = s:UpName(a:filetype)
        Tlibtrace 'checksyntax', filetype, update, a:000, a:0, type(a:1)
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
                Tlibtrace 'checksyntax', make_def
                if !has_key(make_def, 'cmd') || !empty(make_def.cmd)
                    let [update_name, name] = s:UpNameFromDef(make_def)
                    if empty(name)
                        throw 'CheckSyntax: Name must not be empty: '. filetype .': '. string(make_def)
                    elseif empty(filter(copy(s:mandatory), 'has_key(make_def, v:val)'))
                        throw 'CheckSyntax: One of '. join(s:mandatory, ', ') .' must be defined: '. filetype .': '. string(make_def)
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


function! checksyntax#GetChecker(filetype, ...) abort "{{{3
    call checksyntax#Require(a:filetype)
    let alts = get(get(s:checkers, a:filetype, {}), 'alternatives', {})
    let name_rx = a:0 >= 1 ? a:1 : ''
    if empty(name_rx)
        return values(alts)
    else
        return values(filter(copy(alts), 'v:val.name =~# name_rx'))
    endif
endf


" :nodoc:
" Run |:make| based on a syntax checker definition.
function! s:RunSyncWithEFM(make_def) abort "{{{3
    Tlibtrace 'checksyntax', a:make_def
    let type = get(a:make_def, 'listtype', 'loc')
    let shellpipe = &shellpipe
    let errorformat = &errorformat
    if has_key(a:make_def, 'shellpipe')
        let &shellpipe = get(a:make_def, 'shellpipe')
        Tlibtrace 'checksyntax', &shellpipe
    endif
    if has_key(a:make_def, 'efm')
        let &errorformat = get(a:make_def, 'efm')
        Tlibtrace 'checksyntax', &errorformat
    endif
    try
        if has_key(a:make_def, 'cmd')
            let cmddef = s:ExtractCompilerParams(a:make_def, '%', a:make_def.cmd)
            let cmd = s:NativeCmd(cmddef.cmd)
            Tlibtrace 'checksyntax', cmd
            let rv = a:make_def.GetExpr(cmd)
            Tlibtrace 'checksyntax', rv, getqflist()
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

function! s:ConvertFilenames(make_def, props) abort "{{{3
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
                Tlibtrace 'checksyntax', filename, convert_filename
                let cmd = printf(convert_filename, shellescape(filename))
                Tlibtrace 'checksyntax', cmd
                let filename = system(cmd)
                let filename = substitute(filename, '\n$', '', '')
                let s:convert_filenames[convert_filename][filename] = filename
            endif
            Tlibtrace 'checksyntax', filename
        endif
        let a:make_def[key] = filename
    endfor
    return a:make_def
endf


let s:loaded_checkers = {}

" :nodoc:
function! checksyntax#Require(filetype) abort "{{{3
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


function! s:NativeCmd(cmd) abort "{{{3
    if !empty(g:checksyntax#cygwin_expr) && s:CygwinBin(matchstr(a:cmd, '^\S\+'))
        let cmd = eval(printf(g:checksyntax#cygwin_expr, string(a:cmd)))
        Tlibtrace 'checksyntax', cmd
        return cmd
    else
        return a:cmd
    endif
endf


" :nodoc:
function! s:Cmd(make_def) abort "{{{3
    if has_key(a:make_def, 'cmd')
        let cmd = matchstr(a:make_def.cmd, '^\(\\\s\|\S\+\|"\([^"]\|\\"\)\+"\)\+')
    else
        let cmd = ''
    endif
    return cmd
endf


" :nodoc:
function! s:UpName(upname) abort "{{{3
    Tlibtrace 'checksyntax', a:upname
    if a:upname =~# '?$'
        let update = 0
        let name = substitute(a:upname, '?$', '', '')
    else
        let update = 1
        let name = a:upname
    endif
    Tlibtrace 'checksyntax', update, name
    return [update, name]
endf


" :nodoc:
function! s:UpNameFromDef(make_def) abort "{{{3
    let name = get(a:make_def, 'name', '')
    if empty(name)
        let name = matchstr(get(a:make_def, 'compiler', ''), '[^\/]\+$')
    endif
    if empty(name)
        let name = s:Cmd(a:make_def)
    endif
    Tlibtrace 'checksyntax', name
    return s:UpName(name)
endf


function! s:ValidAlternative(make_def) abort "{{{3
    Tlibtrace 'checksyntax', a:make_def
    if has_key(a:make_def, 'if')
        return eval(a:make_def.if)
    elseif has_key(a:make_def, 'if_executable')
        return s:Executable(a:make_def.if_executable)
    elseif has_key(a:make_def, 'cmd')
        let cmd = s:Cmd(a:make_def)
        Tlibtrace 'checksyntax', cmd
        return !empty(cmd) && s:Executable(cmd)
    endif
    return 1
endf


function! s:GetValidAlternatives(filetype, run_alternatives, alternatives) abort "{{{3
    Tlibtrace 'checksyntax', a:filetype, a:run_alternatives, a:alternatives
    let valid = {}
    for name in get(get(s:checkers, a:filetype, {}), 'order', [])
        let alternative = a:alternatives[name]
        Tlibtrace 'checksyntax', alternative
        if s:ValidAlternative(alternative)
            if has_key(alternative, 'checkergen')
                let alt1 = deepcopy(alternative)
                call remove(alt1, 'checkergen')
                let alts = call(alternative.checkergen, [alt1])
                let valid_alts = filter(alts, 's:ValidAlternative(v:val)')
                if !empty(valid_alts)
                    call extend(valid, valid_alts)
                endif
            else
                let valid[name] = alternative
            endif
            if a:run_alternatives =~? '\<first\>'
                let preferred_rx = get(g:checksyntax#preferred, a:filetype, '')
                if empty(preferred_rx) || name =~ preferred_rx
                    break
                endif
            endif
        endif
    endfor
    return valid
endf


let s:run_alternatives_all = 0

" :nodoc:
function! checksyntax#RunAlternativesMode(make_def) abort "{{{3
    let rv = s:run_alternatives_all ? g:checksyntax#run_all_alternatives : get(a:make_def, 'run_alternatives', g:checksyntax#run_alternatives)
    Tlibtrace 'checksyntax', a:make_def, rv
    return rv
endf


function! s:GetDef(filetype) abort "{{{3
    Tlibtrace 'checksyntax', a:filetype
    if has_key(s:checkers, a:filetype)
        let dict = s:checkers
        let rv = s:checkers[a:filetype]
    else
        let dict = {}
        let rv = {}
    endif
    if !empty(dict)
        let alternatives = get(rv, 'alternatives', {})
        Tlibtrace 'checksyntax', alternatives
        if !empty(alternatives)
            let alternatives = s:GetValidAlternatives(a:filetype, checksyntax#RunAlternativesMode(rv), alternatives)
            Tlibtrace 'checksyntax', alternatives
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


let s:issues = {
            \ 'CheckSyntaxFail': function('CheckSyntaxFail'),
            \ 'CheckSyntaxSucceed': function('CheckSyntaxSucceed')}


function! checksyntax#NewIssuesList(type) abort "{{{3
    let lst = copy(s:issues)
    call lst.Reset(a:type)
    return lst
endf


function! s:issues.Reset(...) abort dict "{{{3
    let self.type = a:0 >= 1 ? a:1 : 'loc'
    let self.issues = []
    let self.jobs = {}
endf


function! s:issues.AddList(name, make_def, type) abort dict "{{{3
    Tlibtrace 'checksyntax', a:name, a:make_def, a:type
    if a:type ==# 'qfl'
        let self.type = a:type
    endif
    let issues = checksyntax#GetList(a:name, a:make_def, a:type)
    call checksyntax#Debug('AddList: '. len(issues))
    Tlibtrace 'checksyntax', len(issues)
    if !empty(issues)
        let self.issues += issues
    endif
    return issues
endf


function! s:issues.Display(manually, bg, ...) abort dict "{{{3
    call checksyntax#Debug('Display: '. len(self.issues))
    let obj = a:0 >= 1 ? a:1 : s:prototypes[self.type]
    if empty(self.issues)
        call obj.Set(self.issues)
        call self.CheckSyntaxSucceed(self.type, a:manually)
    else
        Tlibtrace 'checksyntax', self.issues
        call sort(self.issues, 's:CompareIssues')
        Tlibtrace 'checksyntax', self.issues
        Tlibtrace 'checksyntax', self.type
        call obj.Set(self.issues)
        Tlibtrace 'checksyntax', self.type, a:manually, a:bg
        call self.CheckSyntaxFail(self.type, a:manually, a:bg)
    endif
endf


function! s:issues.WaitFor(make_def) abort dict "{{{3
    if has_key(self.jobs, a:make_def.job_id)
        echom 'Checksyntax#WaitFor: job_id already registered:' a:make_def.job_id string(keys(self.jobs))
    endif
    let self.jobs[a:make_def.job_id] = a:make_def
endf


function! s:issues.Done(make_def) dict abort "{{{3
    let njobs = checksyntax#RemoveJob(a:make_def.job_id)
    if has_key(self.jobs, a:make_def.job_id)
        call remove(self.jobs, a:make_def.job_id)
    else
        echom 'CheckSyntax#Done: Didn''t expect job:' a:make_def.job_id
    endif
    let list = self.AddList(a:make_def.name, a:make_def, a:make_def.async_type)
    Tlibtrace 'checksyntax2', list
    Tlibtrace 'checksyntax', a:make_def.name, len(list)
    call checksyntax#Debug(printf('Processing %s (%s items)', a:make_def.name, len(list)))
    if empty(self.jobs)
        let bg = a:make_def.bg
        let bg = 1
        let manually = a:make_def.manually || g:checksyntax#debug
        " if a:make_def.async_type ==# 'loc' && bufnr('%') != a:make_def.bufnr
        "     exec 'autocmd! CheckSyntax BufWinEnter <buffer='. a:make_def.bufnr .'> call call(function(s:issues.DelayedDisplay, [a:make_def.bufnr, manually, bg, a:make_def], self))'
        " else
        call self.Display(manually, bg, a:make_def)
        " endif
    endif
endf


function! s:issues.DelayedDisplay(bufnr, manually, bg, obj) abort dict "{{{3
    autocmd! CheckSyntax BufWinEnter <buffer>
    call self.Display(a:manually, a:bg, a:obj)
endf


function! checksyntax#Debug(msg, ...) abort "{{{3
    let level = a:0 >= 1 ? a:1 : 1
    if g:checksyntax#debug >= level
        echom 'CheckSyntax:' a:msg
    endif
endf


" :def: function! checksyntax#Check(manually, ?bang='', ?filetype=&ft, ?preferred_rx='')
" Perform a syntax check.
" If bang is not empty, run all alternatives (see 
" |g:checksyntax#run_alternatives|).
" If filetype is empty, the current buffer's 'filetype' will be used.
" If background is true, display the list of issues in the background, 
" i.e. the active window will keep the focus.
function! checksyntax#Check(manually, ...) abort
    let bang = a:0 >= 1 ? !empty(a:1) : 0
    let filetype   = a:0 >= 2 && a:2 !=# '' && a:2 !=# '*' ? a:2 : &filetype
    " let bg   = a:0 >= 3 && !empty(a:3)  && a:3 !=# '*' ? a:3 : 1
    let bg   = !a:manually || g:checksyntax#background
    let arg_preferred_rx = a:0 >= 3 && a:3 !=# '' ? a:3 : ''
    Tlibtrace 'checksyntax', a:manually, bang, filetype, bg, arg_preferred_rx
    let s:run_alternatives_all = bang
    let wd = getcwd()
    let bd = expand('%:p:h')
    let will_display = 0
    try
        let global_issues = checksyntax#NewIssuesList('qfl')
        let buffer_issues = checksyntax#NewIssuesList('loc')
        let defs = s:GetDefsByFiletype(a:manually, filetype)
        Tlibtrace 'checksyntax', defs
        if has_key(defs, 'make_defs') && !empty(defs.make_defs)
            if !exists('b:checksyntax_runs')
                let b:checksyntax_runs = 1
            else
                let b:checksyntax_runs += 1
            endif
            Tlibtrace 'checksyntax', &makeprg, &l:makeprg, &g:makeprg, &errorformat
            if defs.run_alternatives =~? '\<first\>' && has_key(g:checksyntax#preferred, filetype)
                let preferred_rx = g:checksyntax#preferred[filetype]
                let defs.make_defs = filter(defs.make_defs, 's:UpNameFromDef(v:val)[1] =~ preferred_rx')
            endif
            if !empty(arg_preferred_rx)
                let defs.make_defs = filter(defs.make_defs, 's:UpNameFromDef(v:val)[1] =~ arg_preferred_rx')
            endif
            let async = !empty(g:checksyntax#async_runner) && defs.run_alternatives =~? '\<async\>'
            Tlibtrace 'checksyntax', async
            " if !empty(s:async_pending)
            "     if !a:manually && async
            "         echohl WarningMsg
            "         echo 'CheckSyntax: Still waiting for async results ...'
            "         echohl NONE
            "         return
            "     else
            "         let s:async_pending = {}
            "     endif
            " endif
            let props = {
                        \ 'bg': bg,
                        \ 'bufnr': bufnr('%'),
                        \ 'filename': expand('%'),
                        \ 'altname': expand('#'),
                        \ 'manually': a:manually,
                        \ }
            Tlibtrace 'checksyntax', keys(defs.make_defs)
            for [name, make_def] in items(defs.make_defs)
                call checksyntax#Debug('run '. name .' (async='. async .')')
                Tlibtrace 'checksyntax', name, make_def, async
                let make_def1 = copy(make_def)
                let type = get(make_def1, 'listtype', 'loc')
                let make_def1 = extend(make_def1, s:prototypes[type], 'keep')
                let make_def1.issues = type ==# 'loc' ? buffer_issues : global_issues
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
            if empty(s:async_pending)
                let will_display = 1
            endif
        endif
    finally
        let s:run_alternatives_all = 0
        if will_display
            call global_issues.Display(a:manually, bg)
            call buffer_issues.Display(a:manually, bg)
        endif
    endtry
    redraw!
endf


function! s:Status() abort "{{{3
    if empty(s:async_pending)
        echo 'CheckSyntax: No pending jobs'
    else
        echo 'CheckSyntax: Pending jobs:'
        for [job_id, make_def] in items(s:async_pending)
            echo printf('  %s: bufnr=%s, cmd=%s',
                        \ job_id,
                        \ make_def.bufnr, 
                        \ make_def.name
                        \ )
        endfor
    endif
endf


function! s:GetDefsByFiletype(manually, filetype) abort "{{{3
    Tlibtrace 'checksyntax', a:manually, a:filetype
    let defs = {'mode': '', 'make_defs': {}}
    call checksyntax#Require(a:filetype)
    " let defs.mode = 'auto'
    let make_def = a:manually ? {} : s:GetDef(a:filetype .',auto')
    Tlibtrace 'checksyntax', 1, make_def
    if empty(make_def)
        let make_def = s:GetDef(a:filetype)
        Tlibtrace 'checksyntax', 2, make_def
    endif
    if &modified
        if has_key(make_def, 'modified')
            let make_def = s:GetDef(make_def.modified)
            Tlibtrace 'checksyntax', 3, make_def
        else
            echohl WarningMsg
            echom 'Buffer was modified. Please save it before calling :CheckSyntax.'
            echohl NONE
            return {}
        endif
    endif
    Tlibtrace 'checksyntax', make_def
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
    Tlibtrace 'checksyntax', auto
    if !(a:manually || auto)
        return defs
    endif
    let defs.run_alternatives = checksyntax#RunAlternativesMode(make_def)
    Tlibtrace 'checksyntax', &makeprg, &l:makeprg, &g:makeprg, &errorformat
    Tlibtrace 'checksyntax', make_def
    let defs.make_defs = get(make_def, 'alternatives', {'*': make_def})
    Tlibtrace 'checksyntax', defs
    return defs
endf


function! s:CompareIssues(i1, i2) abort "{{{3
    let l1 = get(a:i1, 'lnum', 0)
    let l2 = get(a:i2, 'lnum', 0)
    Tlibtrace 'checksyntax', l1, l2, type(l1), type(l2)
    return l1 == l2 ? 0 : l1 > l2 ? 1 : -1
endf


let s:compiler_params = {}

function! s:GetCompilerParams(make_def) abort "{{{3
    let compiler = a:make_def.compiler
    if !has_key(s:compiler_params, compiler)
        let s:compiler_params[compiler] = s:WithCompiler(compiler,
                    \ {'return': function('s:ExtractCompilerParams', [a:make_def, ''])},
                    \ {})
    endif
    return s:compiler_params[compiler]
endf


function! s:WithCompiler(compiler, exec, default) abort "{{{3
    Tlibtrace 'checksyntax', a:compiler, a:exec, a:default
    if exists('g:current_compiler')
        let gcc = g:current_compiler
    else
        let gcc = ''
    endif
    if exists('b:current_compiler')
        let bcc = b:current_compiler
    else
        let bcc = ''
    endif
    let efm = &errorformat
    let mprg = &makeprg
    try
        for c in [a:compiler, 'checksyntax/'. a:compiler]
            let found = findfile('compiler/'. c .'.vim', &runtimepath)
            Tlibtrace 'checksyntax', c, found
            if !empty(found)
                set makeprg=
                exec 'compiler' c
                Tlibtrace 'checksyntax', &makeprg
                if !empty(&makeprg)
                    if has_key(a:exec, 'call')
                        call call(a:exec.call, [])
                    endif
                    if has_key(a:exec, 'return')
                        return call(a:exec.return, [])
                    endif
                endif
                break
            endif
        endfor
    finally
        if gcc !=# ''
            let g:current_compiler = gcc
        else
            unlet! g:current_compiler
        endif
        if bcc !=# ''
            let g:current_compiler = bcc
        else
            unlet! g:current_compiler
        endif
        let &errorformat = efm
        let &makeprg = mprg
    endtry
    return a:default
endf


function! s:RunSyncChecker(filetype, make_def) abort
    let bufnr = bufnr('%')
    let pos = getpos('.')
    let type = get(a:make_def, 'listtype', 'loc')
    try
        if has_key(a:make_def, 'compiler')
            " <+TODO+> Use s:ExtractCompilerParams and run s:RunSyncWithEFM
            let args = get(a:make_def, 'compiler_args', '%')
            let rv = s:WithCompiler(a:make_def.compiler,
                        \ {'call': function(a:make_def.Make, [args])},
                        \ 1)
        else
            let rv = s:RunSyncWithEFM(a:make_def)
        endif
        Tlibtrace 'checksyntax', rv
        return rv
    catch
        echohl Error
        echom 'Exception' v:exception 'from' v:throwpoint
        echom v:errmsg
        echohl NONE
    finally
        Tlibtrace 'checksyntax', pos, bufnr
        if bufnr != bufnr('%')
            exec bufnr 'buffer'
        endif
        call setpos('.', pos)
    endtry
    return 0
endf


function! s:Run_async(make_def) abort "{{{3
    Tlibtrace 'checksyntax', a:make_def
    let make_def = a:make_def
    let cmd = checksyntax#GetMakerParam(make_def, g:checksyntax#async_runner, 'cmd', '')
    Tlibtrace 'checksyntax', cmd
    if !empty(cmd)
        " TODO Clarify what the cmd_args field is used for
        if has_key(a:make_def, 'cmd_args')
            " let cmddef = s:ExtractCompilerParams(a:make_def, '', a:make_def.cmd)
            " let cmd = cmddef.cmd
        else
            let cmd .= ' '. escape(make_def.filename, '"''\ ')
        endif
    elseif has_key(make_def, 'compiler')
        let compiler_def = s:GetCompilerParams(make_def)
        Tlibtrace 'checksyntax', compiler_def
        if !empty(compiler_def)
            let cmd = compiler_def.cmd
            let make_def.efm = compiler_def.efm
        endif
    endif
    Tlibtrace 'checksyntax', cmd
    if !empty(cmd)
        try
            let cmd = s:NativeCmd(cmd)
            Tlibtrace 'checksyntax', cmd
            let rv = checksyntax#async#{g:checksyntax#async_runner}#Run(cmd, make_def)
            call a:make_def.issues.WaitFor(a:make_def)
            call checksyntax#AddJob(make_def)
            return rv
        catch /^Vim\%((\a\+)\)\=:E117/
            echohl Error
            echom v:exception
            echom 'Checksyntax: Unsupported value for g:checksyntax#async_runner: '. string(g:checksyntax#async_runner)
            echohl NONE
            let g:checksyntax#async_runner = ''
            return 0
        endtry
    else
        echohl WarningMsg
        echom 'CheckSyntax: Cannot run asynchronously:' make_def.name
        echohl NONE
        return 0
    endif
endf


function! s:ReplaceMakeArgs(make_def, cmd, args) abort "{{{3
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


function! s:Filename(make_def, type, mod) abort "{{{3
    if a:type ==# '%'
        let filename = a:make_def.filename
    elseif a:type ==# '#'
        let filename = a:make_def.altname
    else
        throw 'CheckSyntax/s:Filename: Internal error: type = '. a:type
    endif
    if !empty(a:mod)
        let filename = fnamemodify(filename, a:mod)
    endif
    return escape(filename, '\')
endf


function! checksyntax#GetMakerParam(opts, maker, name, default) abort "{{{3
    let mopts = get(a:opts, a:maker, {})
    let val = get(mopts, a:name, get(a:opts, a:name, a:default))
    return val
endf


function! s:ExtractCompilerParams(make_def, args, ...) abort "{{{3
    let cmd = a:0 >= 1 ? a:1 : &makeprg
    let args = get(a:make_def, 'compiler_args', a:args)
    let cmd = s:ReplaceMakeArgs(a:make_def, cmd, args)
    let compiler_def = {
                \ 'cmd': cmd,
                \ 'efm': &errorformat
                \ }
    Tlibtrace 'checksyntax', compiler_def
    return compiler_def
endf


let s:status_expr = '"Checks=".checksyntax#Status()'

function! checksyntax#AddJob(make_def) abort "{{{3
    Tlibtrace 'checksyntax', a:make_def.job_id
    let s:async_pending[a:make_def.job_id] = a:make_def
    " call checksyntax#SetStatusMessage()
    if exists('g:tstatus_exprs')
        if index(g:tstatus_exprs, s:status_expr) == -1
            call add(g:tstatus_exprs, s:status_expr)
        endif
        call TStatusForceUpdate()
    endif
endf


function! checksyntax#RemoveJob(job_id) abort "{{{3
    Tlibtrace 'checksyntax', a:job_id
    let rv = has_key(s:async_pending, a:job_id)
    if rv
        call remove(s:async_pending, a:job_id)
        " call checksyntax#SetStatusMessage()
        if empty(s:async_pending) && exists('g:tstatus_exprs')
            let idx = index(g:tstatus_exprs, s:status_expr)
            if idx != -1
                call remove(g:tstatus_exprs, idx)
            endif
            call TStatusForceUpdate()
        endif
    endif
    return rv ? len(s:async_pending) : -1
endf


function! checksyntax#Status() abort "{{{3
    return len(s:async_pending)
endf


" function! checksyntax#SetStatusMessage() abort "{{{3
"     let pending = checksyntax#Status()
"     if pending > 0
"         let g:checksyntax_status = pending
"     elseif exists('g:checksyntax_status')
"         unlet g:checksyntax_status
"     endif
" endf


" if exists(':TStatusregister') == 2
"     TStatusregister g:checksyntax_status=Checks
" endif


function! s:Run_sync(name, filetype, make_def) abort "{{{3
    Tlibtrace 'checksyntax', a:name, a:filetype, a:make_def
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
        call make_def.issues.AddList(a:name, make_def, type)
        return 1
    else
        return 0
    endif
endf


function! checksyntax#GetList(name, make_def, type) abort "{{{3
    Tlibtrace 'checksyntax', a:type
    let list = a:make_def.Get()
    Tlibtrace 'checksyntax', list
    Tlibtrace 'checksyntax', 1, len(list), has_key(a:make_def, 'process_list')
    if !empty(list) && has_key(a:make_def, 'process_list')
        Tlibtrace 'checksyntax', a:make_def.process_list
        let list = call(a:make_def.process_list, [list])
        Tlibtrace 'checksyntax', 2, len(list)
    endif
    if !empty(list)
        let list = filter(list, 's:FilterItem(a:make_def, v:val)')
        Tlibtrace 'checksyntax', 3, len(list)
        Tlibtrace 'checksyntax', a:type, list
        if !empty(list)
            let list = map(list, 's:CompleteItem(a:name, a:make_def, v:val)')
            Tlibtrace 'checksyntax', 4, len(list)
            Tlibtrace 'checksyntax', a:type, list
        endif
    endif
    let ulist = []
    let items = {}
    Tlibtrace 'checksyntax', list
    for item in list
        let key = string(item)
        if !has_key(items, key)
            call add(ulist, item)
            let items[key] = 1
        endif
    endfor
    Tlibtrace 'checksyntax', ulist
    return ulist
endf


function! s:CompleteItem(name, make_def, val) abort "{{{3
    Tlibtrace 'checksyntax', a:name, a:make_def, a:val
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
    Tlibtrace 'checksyntax', a:val
    return a:val
endf


function! s:FilterItem(make_def, val) abort "{{{3
    if a:val.lnum == 0 && a:val.pattern ==# ''
        Tlibtrace 'checksyntax', 'reject: lnum, pattern', a:val
        return 0
    elseif !empty(get(a:make_def, 'ignore_rx', '')) && get(a:val, 'text', '') =~# a:make_def.ignore_rx
        Tlibtrace 'checksyntax', 'reject: ignore_rx', a:val
        return 0
    elseif has_key(a:val, 'nr') && has_key(a:make_def, 'ignore_nr') && index(a:make_def.ignore_nr, a:val.nr) != -1
        Tlibtrace 'checksyntax', 'reject: nr, ignore_nr', a:val
        return 0
    elseif has_key(a:make_def, 'buffers')
        let buffers = a:make_def.buffers
        Tlibtrace 'checksyntax', 'reject: buffers', a:val, buffers, a:make_def.bufnr
        if buffers ==# 'listed' && !buflisted(a:val.bufnr)
            return 0
        elseif buffers ==# 'current' && a:val.bufnr != a:make_def.bufnr
            return 0
        endif
    endif
    return 1
endf


function! checksyntax#NullOutput(flag) abort "{{{3
    if empty(g:checksyntax#null)
        return ''
    else
        return a:flag .' '. g:checksyntax#null
    endif
endf


" If cmd seems to be a cygwin executable, use cygpath to convert 
" filenames. This assumes that cygwin's which command returns full 
" filenames for non-cygwin executables.
function! checksyntax#MaybeUseCygpath(cmd) abort "{{{3
    " echom "DBG" a:cmd
    if g:checksyntax#check_cygpath && s:CygwinBin(a:cmd)
        return 'cygpath -u %s'
    endif
    return ''
endf


function! checksyntax#SetupSyntax(syntax) abort "{{{3
    let after_syntax = []
    if index(g:checksyntax#enable_syntax, a:syntax) != -1
        call add(after_syntax, a:syntax)
    endif
    if !empty(g:checksyntax#enable_syntax_)
        let after_syntax += g:checksyntax#enable_syntax_
    endif
    if exists('g:checksyntax#enable_syntax_'. a:syntax)
        let after_syntax += g:checksyntax#enable_syntax_{a:syntax}
    endif
    if exists('b:checksyntax_enable_syntax')
        let after_syntax += b:checksyntax_enable_syntax
    endif
    Tlibtrace 'checksyntax', after_syntax
    redir => hidef
    silent! hi CheckSyntaxError
    redir END
    if hidef !~# '\<guisp\>'
        let fg = &background ==# 'dark' ? 'yellow' : 'brown'
        exec 'hi CheckSyntaxError term=standout cterm=underline ctermfg=red gui=undercurl guisp=red guifg='. fg
        exec 'hi CheckSyntaxWarning term=standout cterm=underline ctermfg=cyan gui=undercurl guisp=cyan guifg='. fg
    endif
    for asyn in after_syntax
        exec 'runtime! autoload/checksyntax/syntax/'. asyn .'.vim'
    endfor
endf


