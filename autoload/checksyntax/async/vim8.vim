" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    89


let s:prototype = {'in_mode': 'nl', 'out_mode': 'nl', 'err_mode': 'nl'}


function! s:Callback(ch, msg) abort dict "{{{3
    call add(self.lines, a:msg)
endf


function! s:Exit_cb(job, status) abort dict "{{{3
    let jobs = checksyntax#RemoveJob(self.job_id)
    Tlibtrace 'checksyntax', jobs
    let errorformat = &errorformat
    try
        Tlibtrace 'checksyntax', self.async_type, self.bufnr, bufnr('%')
        if self.async_type != 'loc' || self.bufnr == bufnr('%')
            let &errorformat = self.async_efm
            exec self.async_cmd 'self.lines'
            let list = g:checksyntax#issues.AddList(self.name, self, self.async_type)
            if g:checksyntax#debug
                echo
                echom printf('CheckSyntax: Processing %s (%s items)', self.name, len(list))
            endif
            if jobs == 0
                let bg = self.bg
                let bg = 1
                let manually = self.manually
                let manually = g:checksyntax#debug
                call g:checksyntax#issues.Display(manually, bg)
            endif
        endif
    finally
        let &errorformat = errorformat
    endtry
endf


function! checksyntax#async#vim8#New(ext) abort "{{{3
    let o = extend(deepcopy(s:prototype), a:ext)
    return o
endf

function! checksyntax#async#vim8#Run(cmd, make_def) "{{{3
    Tlibtrace 'checksyntax', a:cmd, a:make_def
    let make_def = a:make_def
    let make_def.lines = []
    let type = get(a:make_def, 'listtype', 'loc')
    let make_def.async_cmd = type == 'loc' ? 'lgetexpr' : 'cgetexpr'
    let make_def.async_type = type
    let make_def.async_efm = get(a:make_def, 'efm', &errorformat)
    let opts = checksyntax#async#vim8#New({})
    let opts.callback = function('s:Callback', [], make_def)
    let opts.exit_cb = function('s:Exit_cb', [], make_def)
    let job = job_start(a:cmd, opts)
    Tlibtrace 'checksyntax', job
    return 1
endf

