" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    81


let s:async_handler = {}


function! s:async_handler.get(temp_file_name) dict abort
    Tlibtrace 'checksyntax', a:job, a:status, self.job_id
    call checksyntax#Debug('vim8 exit: '. self.job_id)
    let errorformat = &errorformat
    try
        Tlibtrace 'checksyntax', self.async_type, self.bufnr, bufnr('%')
        if self.async_type !=# 'loc' || self.bufnr == bufnr('%')
            let &errorformat = self.async_efm
            Tlibtrace 'checksyntax', &errorformat
            call checksyntax#Debug('vim8 &errorformat='. &errorformat, 2)
            Tlibtrace 'checksyntax', self.async_efm
            Tlibtrace 'checksyntax', self.async_cmd, a:temp_file_name
            " let lines = readfile(a:temp_file_name) " DBG
            " Tlibtrace 'checksyntax', lines
            " echom "DBG" self.async_cmd a:temp_file_name
            exec self.async_cmd a:temp_file_name
            call self.issues.Done(self)
        endif
    finally
        let &errorformat = errorformat
    endtry
endf


function! s:AsyncCommandHandler(make_def) abort
    Tlibtrace 'checksyntax', a:make_def
    let type = get(a:make_def, 'listtype', 'loc')
    let async_handler = {
                \ 'async_cmd': type ==# 'loc' ? 'lgetfile' : 'cgetfile',
                \ 'async_type': type,
                \ 'async_efm': get(a:make_def, 'efm', &errorformat),
                \ }
    call extend(async_handler, a:make_def)
    call extend(async_handler, s:async_handler, 'keep')
    Tlibtrace 'checksyntax', async_handler
    return asynccommand#tab_restore(async_handler)
endf


function! checksyntax#async#asynccommand#Run(cmd, make_def) abort "{{{3
    Tlibtrace 'checksyntax', a:cmd, a:make_def
    let async_handler = s:AsyncCommandHandler(a:make_def)
    Tlibtrace 'checksyntax', async_handler
    call asynccommand#run(a:cmd, async_handler)
    return 1
endf

