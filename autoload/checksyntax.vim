" checksyntax.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-01-03.
" @Last Change: 2010-02-24.
" @Revision:    0.0.9

let s:save_cpo = &cpo
set cpo&vim
" call tlog#Log('Load: '. expand('<sfile>')) " vimtlib-sfile


if !exists('g:checksyntax_failrx')
    let g:checksyntax_failrx = '\ *\(\d \f\{-}:\)\?\d\{-}:'
endif

""" Php specific
"""""" Check syntax
if !exists('g:checksyntax_cmd_php')
    let g:checksyntax_cmd_php  = 'php -l'
endif
if !exists('g:checksyntax_efm_php')
    let g:checksyntax_efm_php  = '%*[^:]: %m in %f on line %l'
endif
if !exists('g:checksyntax_okrx_php')
    let g:checksyntax_okrx_php = 'No syntax errors detected in '
endif
" if !exists('g:checksyntax_failrx_php')
"     let g:checksyntax_failrx_php = 'Parse error: \|Error parsing'
" endif
if !exists('g:checksyntax_auto_php')
    let g:checksyntax_auto_php = 1
endif

"""""" Parse
if !exists('g:checksyntax_cmd_phpp')
    let g:checksyntax_cmd_phpp = 'php -f'
endif
if !exists('g:checksyntax_efm_phpp')
    let g:checksyntax_efm_phpp = g:checksyntax_efm_php
endif
if !exists('g:checksyntax_okrx_phpp')
    let g:checksyntax_okrx_phpp = g:checksyntax_okrx_php
endif
" if !exists('g:checksyntax_failrx_phpp')
"     let g:checksyntax_failrx_phpp = '^Parse error: '
" endif
if !exists('g:checksyntax_auto_phpp')
    let g:checksyntax_auto_phpp = g:checksyntax_auto_php
endif

if !exists('g:checksyntax_alt_php')
    let g:checksyntax_alt_php = 'phpp'
endif

autocmd CheckSyntax BufReadPost *.php if exists(':EclimValidate') && !empty(eclim#project#util#GetCurrentProjectName()) | let b:checksyntax_auto_php = 0 | let b:checksyntax_auto_phpp = 0 | endif


""" JavaScript specific
if !exists('g:checksyntax_cmd_javascript')
    let g:checksyntax_cmd_javascript = 'jsl -nofilelisting -nocontext -nosummary -nologo -process'
endif
if !exists('g:checksyntax_okrx_javascript')
    let g:checksyntax_okrx_javascript = '0 error(s), 0 warning(s)'
endif
" if !exists('g:checksyntax_auto_javascript')
"     let g:checksyntax_auto_javascript = 0
" endif


""" Ruby specific
if !exists('g:checksyntax_cmd_ruby')
    let g:checksyntax_cmd_ruby = 'ruby -c'
endif
if !exists('g:checksyntax_okrx_ruby')
    let g:checksyntax_okrx_ruby = 'Syntax OK\|No Errors'
endif
if !exists('g:checksyntax_auto_ruby')
    " let g:checksyntax_auto_ruby = 1
    let g:checksyntax_auto_ruby = 0
endif
if !exists('*CheckSyntax_prepare_ruby')
    fun! CheckSyntax_prepare_ruby()
        compiler ruby
    endf
endif

""" Viki specific
if !exists('g:checksyntax_cmd_viki')
    let g:checksyntax_cmd_viki = 'deplate -f null'
endif
if !exists('g:checksyntax_auto_viki')
    " let g:checksyntax_auto_viki = 1
    let g:checksyntax_auto_viki = 0
endif
" if !exists('*CheckSyntax_prepare_viki')
"     fun! CheckSyntax_prepare_viki()
"         compiler deplate
"     endf
" endif

""" chktex (LaTeX specific)
if !exists('g:checksyntax_cmd_tex')
    let g:checksyntax_cmd_tex = 'chktex -q -v0'
endif
if !exists('g:checksyntax_auto_tex')
    " File:Line:Column:Warning number:Warning message
    let g:checksyntax_efm_tex  = '%f:%l:%m'
endif
if !exists('g:checksyntax_auto_tex')
    " let g:checksyntax_auto_tex = 1
    let g:checksyntax_auto_tex = 0
endif

""" c, cpp
if !exists('g:checksyntax_compiler_c')
    let g:checksyntax_compiler_c = 'splint'
endif
if !exists('g:checksyntax_compiler_cpp')
    let g:checksyntax_compiler_cpp = 'splint'
endif

""" java
if !exists('g:checksyntax_compiler_java')
    let g:checksyntax_cmd_java = '*checksyntax#Jlint'
endif
function! checksyntax#Jlint() "{{{3
    let filename = expand('%:r') .'.class'
    " TLogVAR filename
    return 'jlint -done '. shellescape(filename)
endf

if !exists('g:checksyntax_alt_java')
    let g:checksyntax_alt_java = 'javaCheckstyle'
endif
if !exists('g:checksyntax_compiler_javaCheckstyle')
    let g:checksyntax_compiler_javaCheckstyle = 'checkstyle'
endif

""" lua
if !exists('g:checksyntax_cmd_lua')
    let g:checksyntax_cmd_lua = 'luac -p'
endif
if !exists('g:checksyntax_auto_lua')
    " File:Line:Column:Warning number:Warning message
    let g:checksyntax_efm_lua  = 'luac\:\ %f:%l:\ %m'
endif
if !exists('g:checksyntax_auto_lua')
    let g:checksyntax_auto_lua = 1
    " let g:checksyntax_auto_lua = 0
endif

""" tidy (HTML)
if !exists('g:checksyntax_compiler_html')
    let g:checksyntax_compiler_html = 'tidy'
endif

""" XML
if !exists('g:checksyntax_compiler_xml')
    let g:checksyntax_compiler_xml = 'xmllint'
endif
if !exists('g:checksyntax_compiler_docbk')
    let g:checksyntax_compiler_docbk = g:checksyntax_compiler_xml
endif

if !exists('*CheckSyntaxSucceed')
    func! CheckSyntaxSucceed(manually)
        cclose
        if a:manually
            echo
            echo 'Syntax ok.'
        endif
    endf
endif

if !exists('*CheckSyntaxFail')
    function! CheckSyntaxFail(manually)
        copen
    endf
endif


" if has('signs') && exists('loaded_tlib') && loaded_tlib >= 32
"     sign define CheckSyntax text=! texthl=Error
"     let s:checksyntax_signs = 1
"     " Clear all checksyntax-related signs.
"     command! CheckSyntaxClearSigns call tlib#signs#ClearAll('CheckSyntax')
" else
"     let s:checksyntax_signs = 0
" endif

function! s:Make()
    try
        " TLogVAR &makeprg
        if &makeprg[0:0] == '*'
            " TLogVAR &makeprg[1 : -1]
            let &makeprg = call(&makeprg[1 : -1], [])
            " TLogVAR &makeprg
            silent make
        else
            silent make %
        endif
        let se=v:shell_error
        " TLogVAR se
        redir => errors
        silent! clist
        redir END
        " TLogVAR errors
        return errors
    catch
        echohl Error
        echom v:errmsg
        echohl NONE
    endtry
    return ''
endf

function! s:GetVar(var, ft, manually) "{{{3
    for context in ['b', 'g']
        if !a:manually && exists(context .':'. a:var .'auto_'. a:ft)
            return {context}:{a:var}auto_{a:ft}
        elseif exists(context .':'. a:var . a:ft)
            return {context}:{a:var}{a:ft}
        endif
    endfor
    return ''
endf


" :def: function! checksyntax#Check(manually, ?bang='', ?type=&ft)
function! checksyntax#Check(manually, ...)
    let bang = a:0 >= 1 && a:1 != '' ? 1 : 0
    let ft   = a:0 >= 2 && a:2 != '' ? a:2 : &filetype
    if bang && exists('g:checksyntax_alt_'. ft)
        let ft = g:checksyntax_alt_{ft}
    endif
    if exists('b:checksyntax_auto_'. ft)
        let auto = b:checksyntax_auto_{ft}
    elseif exists('g:checksyntax_auto_'. ft)
        let auto = g:checksyntax_auto_{ft}
    else
        let auto = 0
    endif
    " TLogVAR auto
    if !(a:manually || auto)
        return
    endif
    if &modified
        echom "Buffer was modified. Please save it before calling :CheckSyntax."
        return
    end
    let compiler = s:GetVar('checksyntax_compiler_', ft, a:manually)
    let makecmd  = s:GetVar('checksyntax_cmd_', ft, a:manually)
    if empty(compiler) && empty(makecmd)
        return
    endif
    " TLogVAR compiler, makecmd
    let mp = &makeprg
    let ef = &errorformat
    let sp = &shellpipe
    try
        if !empty(compiler)
            if exists('g:current_compiler')
                let cc = g:current_compiler
            else
                let cc = ''
            endif
            exec 'compiler '. compiler
        elseif !empty(makecmd)
            let &l:makeprg = makecmd
            if exists('g:checksyntax_shellpipe')
                let &shellpipe = g:checksyntax_shellpipe
                " TLogVAR &shellpipe
            endif
            if exists('g:checksyntax_efm_'. ft)
                let &errorformat = g:checksyntax_efm_{ft}
            else
                set errorformat&
            endif
            " TLogVAR &errorformat
        endif
        " TLogVAR &makeprg, &l:makeprg, &g:makeprg
        if exists('*CheckSyntax_prepare_'. ft)
            call CheckSyntax_prepare_{ft}()
        endif
        let output = s:Make()
        " TLogVAR output
        let failrx = exists('g:checksyntax_failrx_'. ft) ? g:checksyntax_failrx_{ft} : g:checksyntax_failrx
        let okrx   = exists('g:checksyntax_okrx_'. ft) ? g:checksyntax_okrx_{ft} : ''
        " if s:checksyntax_signs
        "     call tlib#signs#ClearAll('CheckSyntax')
        "     call tlib#signs#Mark('CheckSyntax', getqflist())
        " endif
        let qfl = getqflist()
        call filter(qfl, 'v:val.lnum != 0 || v:val.pattern != ""')
        call setqflist(qfl)
        " if output == '' || (okrx != '' && output =~ okrx) || (failrx != '' && output !~ failrx)
        if len(qfl) == 0
            " TLogVAR output, okrx, failrx
            " TLogDBG okrx != '' && output =~ okrx
            " TLogDBG output !~ failrx
            call CheckSyntaxSucceed(a:manually)
        else
            call CheckSyntaxFail(a:manually)
        endif
    finally
        let &l:makeprg     = mp
        let &errorformat = ef
        let &shellpipe   = sp
        " TLogVAR compiler, cc
        if !empty(compiler)
            if exists('g:current_compiler')
                unlet! g:current_compiler
            endif
            if cc != ''
                exec 'compiler '. cc
            endif
        endif
        redraw!
    endtry
endf


let &cpo = s:save_cpo
unlet s:save_cpo
