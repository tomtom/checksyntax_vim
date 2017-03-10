" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    145


let s:prototype = {'in_mode': 'nl', 'out_mode': 'nl', 'err_mode': 'nl'}


function! s:Out_cb(ch, msg) abort dict "{{{3
    Tlibtrace 'checksyntax', a:msg
    call checksyntax#Debug('vim8 output: '. a:msg, 2)
    call add(self.lines, a:msg)
endf


function! s:Err_cb(ch, msg) abort "{{{3
    Tlibtrace 'checksyntax', a:msg
    echoerr a:msg
endf


function! s:Exit_cb(job, status) abort dict "{{{3
    Tlibtrace 'checksyntax', a:job, a:status, self.job_id
    call checksyntax#Debug('vim8 exit: '. self.job_id)
    let errorformat = &errorformat
    try
        Tlibtrace 'checksyntax', self.async_type, self.bufnr, bufnr('%')
        if self.async_type !=# 'loc' || self.bufnr == bufnr('%')
            let &errorformat = self.async_efm
            Tlibtrace 'checksyntax', &errorformat
            call checksyntax#Debug('vim8 &errorformat='. &errorformat, 2)
            exec self.async_cmd 'self.lines'
            call self.issues.Done(self)
        endif
    finally
        let &errorformat = errorformat
    endtry
endf


function! checksyntax#async#vim8#New(ext) abort "{{{3
    let o = extend(deepcopy(s:prototype), a:ext)
    return o
endf

function! checksyntax#async#vim8#Run(cmd, make_def) abort "{{{3
    Tlibtrace 'checksyntax', a:cmd
    Tlibtrace 'checksyntax', a:make_def
    Tlibtrace 'checksyntax', getcwd()
    let make_def = a:make_def
    let make_def.lines = []
    let type = get(a:make_def, 'listtype', 'loc')
    let make_def.async_cmd = type ==# 'loc' ? 'lgetexpr' : 'cgetexpr'
    let make_def.async_type = type
    let make_def.async_efm = checksyntax#GetMakerParam(a:make_def, 'vim8', 'efm', &errorformat)
    let opts = checksyntax#async#vim8#New({})
    let opts.callback = function('s:Out_cb', [], make_def)
    " let opts.out_cb = function('s:Out_cb', [], make_def)
    " let opts.err_cb = function('s:Err_cb', [], make_def)
    let opts.exit_cb = function('s:Exit_cb', [], make_def)
    call checksyntax#Debug('vim8 job: '. a:cmd)
    let job = job_start(a:cmd, opts)
    Tlibtrace 'checksyntax', job
    let input = checksyntax#GetMakerParam(a:make_def, 'vim8', 'input', [])
    if !empty(input)
        Tlibtrace 'checksyntax', input
        let ch = job_getchannel(job)
        for line in input
            sleep 200m
            Tlibtrace 'checksyntax', line
            call checksyntax#Debug('vim8 input: '. line, 2)
            call ch_sendraw(ch, line ."\n")
        endfor
    endif
    Tlibtrace 'checksyntax', job_status(job)
    return 1
endf

