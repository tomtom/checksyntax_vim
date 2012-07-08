" checksyntax.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-01-03.
" @Last Change: 2012-07-08.
" @Revision:    436


if !exists('g:checksyntax#auto_mode')
    " If 1, enable automatically running syntax checkers when saving a 
    " file.
    " If 2, turn on automatic syntax checks for all known filetypes.
    " If 0, disable automatic syntax checks.
    let g:checksyntax#auto_mode = 1   "{{{2
endif

if !exists('g:checksyntax#debug')
    let g:checksyntax#debug = 0
endif

if !exists('g:checksyntax')
    " A dictionary {name/filetype => definition} of syntax checkers, where 
    " definition is a dictionary with the following fields:
    " 
    " Mandatory (either one of the following):
    "   cmd  ... A shell command used as 'makeprg' to check the file.
    "   exec ... A vim command used to check the file.
    "   compiler ... A vim compiler that is used to check the file.
    " 
    " Optional:
    "   auto ... Run automatically when saving a file.
    "   efm  ... An 'errorformat' string.
    "   alt  ... The name of an alternative syntax checker (see 
    "            |:CheckSyntax|).
    "   prepare ... An ex command that is run before doing anything.
    "   ignore_nr ... A list of error numbers that should be ignored.
    "   listtype ... Either loc (default) or qfl
    "   if   ... An expression to test *once* whether a syntax checker 
    "            should be used.
    "   alternatives ... A list of syntax checker definitions (the first 
    "            one with a valid executable is used. If used, no other 
    "            elements are allowed. This list is checked only once.
    "
    " Pre-defined syntax checkers (the respective syntax checker has to 
    " be installed):
    "   php                           ... Syntax check; requires php
    "   phpp (php alternative)        ... Parse php; requires php
    "   javascript                    ... Syntax check; requires either gjslint or jsl
    "   python                        ... Requires pyflakes
    "   pylint (python alternative)   ... Requires pylint
    "   ruby                          ... Requires ruby
    "   viki                          ... Requires deplate
    "   chktex (tex, latex)           ... Requires chktex
    "   c, cpp                        ... Requires splint
    "   java                          ... Requires jlint
    "   checkstyle (java alternative) ... Requires checkstyle
    "   lua                           ... Requires luac
    "   html                          ... Requires tidy
    "   xhtml                         ... Requires tidy
    "   xml                           ... Requires xmllint
    "   docbk                         ... Requires xmllint
    "
    " :read: let g:checksyntax = {...}   "{{{2
    let g:checksyntax = {}
endif


if !exists('g:checksyntax#syntastic_dir')
    " The directory where the syntastic plugin is installed.
    " If non-empty, use syntastic syntax checkers if available.
    " NOTE: Experimental feature.
    let g:checksyntax#syntastic_dir = ''   "{{{2
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


let g:checksyntax#prototypes = {'loc': {}, 'qfl': {}}

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


function! s:Make(filetype, def)
    let bufnr = bufnr('%')
    let pos = getpos('.')
    let type = get(a:def, 'listtype', 'loc')
    try
        if has_key(a:def, 'compiler')

            if exists('g:current_compiler')
                let cc = g:current_compiler
            else
                let cc = ''
            endif
            try
                exec 'compiler '. a:def.compiler
                call g:checksyntax#prototypes[type].Make('')
                return 1
            finally
                if cc != ''
                    let g:current_compiler = cc
                    exec 'compiler '. cc
                endif
            endtry

        elseif has_key(a:def, 'syntastic')

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

function! checksyntax#Require(filetype) "{{{3
    if !has_key(s:loaded_checkers, a:filetype)
        exec 'runtime! autoload/checksyntax/defs/'. a:filetype .'.vim'
        let s:loaded_checkers[a:filetype] = 1
        if !has_key(g:checksyntax, a:filetype)
            if !empty(g:checksyntax#syntastic_dir)
                call checksyntax#syntastic#Require(g:checksyntax, a:filetype)
            endif
        endif
    endif
    return has_key(g:checksyntax, a:filetype)
endf


function! s:GetDef(ft) "{{{3
    if exists('b:checksyntax') && has_key(b:checksyntax, a:ft)
        let dict = b:checksyntax
        let rv = b:checksyntax[a:ft]
    elseif has_key(g:checksyntax, a:ft)
        let dict = g:checksyntax
        let rv = g:checksyntax[a:ft]
    else
        let dict = {}
        let rv = {}
    endif
    if !empty(dict)
        let alternatives = get(rv, 'alternatives', [])
        let use_alternatives = !empty(alternatives)
        while !empty(rv) || use_alternatives
            if !empty(alternatives)
                let rv = remove(alternatives, 0)
            endif
            if has_key(rv, 'if')
                if eval(rv.if)
                    call remove(rv, 'if')
                    break
                else
                    let rv = {}
                    continue
                endif
            endif
            if has_key(rv, 'cmd')
                let cmd = matchstr(rv.cmd, '^\(\\\s\|\S\+\|"\([^"]\|\\"\)\+"\)\+')
                if empty(cmd) && g:checksyntax#debug
                    echom "CheckSyntax: Cannot determine executable name:" rv.cmd printf("(%s)", a:ft)
                elseif executable(cmd) == 0
                    if g:checksyntax#debug
                        echom "CheckSyntax: Not an executable, remove checker:" cmd printf("(%s)", a:ft)
                    endif
                    let rv = {}
                    continue
                endif
            endif
            break
        endwh
        if empty(rv)
            if empty(alternatives)
                call remove(dict, a:ft)
            endif
        else
            if use_alternatives
                let dict[a:ft] = rv
            endif
        endif
    endif
    return rv
endf


" :def: function! checksyntax#Check(manually, ?bang='', ?type=&ft, ?background=1)
function! checksyntax#Check(manually, ...)
    let bang = a:0 >= 1 && a:1 != '' ? 1 : 0
    let ft   = a:0 >= 2 && a:2 != '' ? a:2 : &filetype
    let bg   = a:0 >= 3 && a:3 != '' ? a:3 : 0
    " TLogVAR a:manually, bang, ft, bg
    call checksyntax#Require(ft)
    let def = a:manually ? {} : s:GetDef(ft .',auto')
    if empty(def)
        let def  = s:GetDef(ft)
    endif
    if &modified
        if has_key(def, 'modified')
            let def = s:GetDef(def.modified)
        else
            echohl WarningMsg
            echom "Buffer was modified. Please save it before calling :CheckSyntax."
            echohl NONE
            return
        endif
    endif
    if bang && has_key(def, 'alt')
        let def = s:GetDef(def.alt)
    endif
    " TLogVAR def
    if empty(def)
        return
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
        return
    endif
    if !exists('b:checksyntax_runs')
        let b:checksyntax_runs = 1
    else
        let b:checksyntax_runs += 1
    endif
    " TLogVAR &makeprg, &l:makeprg, &g:makeprg, &errorformat
    exec get(def, 'prepare', '')
    if s:Make(ft, def)
        let type = get(def, 'listtype', 'loc')
        let list = g:checksyntax#prototypes[type].Get()
        " TLogVAR len(list)
        let list = filter(list, 's:FilterItem(def, v:val)')
        let list = map(list, 's:CompleteItem(def, v:val)')
        call g:checksyntax#prototypes[type].Set(list)
        " echom "DBG 1" string(list)
        redraw!
        if len(list) == 0
            call CheckSyntaxSucceed(type, a:manually)
        else
            " TLogVAR type
            " TLogVAR a:manually
            " TLogVAR bg
            call CheckSyntaxFail(type, a:manually, bg)
        endif
    endif
endf


function! s:CompleteItem(def, val) "{{{3
    if get(a:val, 'bufnr', 0) == 0
        let a:val.bufnr = bufnr('%')
    endif
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

