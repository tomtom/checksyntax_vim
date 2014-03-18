" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    43


let s:async_handler = {}


function s:async_handler.get(temp_file_name) dict
    " echom "DBG async_handler.get" self.name self.job_id
    let jobs = checksyntax#RemoveJob(self.job_id)
    if jobs != -1
        let errorformat = &errorformat
        try
            " TLogVAR self.async_type, self.bufnr, bufnr('%')
            if self.async_type != 'loc' || self.bufnr == bufnr('%')
                let &errorformat = self.async_efm
                " TLogVAR self.async_efm
                " TLogVAR self.async_cmd, a:temp_file_name
                " let lines = readfile(a:temp_file_name) " DBG
                " TLogVAR lines
                exec self.async_cmd a:temp_file_name
                let list = g:checksyntax#issues.AddList(self.name, self, self.async_type)
                " TLogVAR list
                " TLogVAR self.name, len(list)
                if g:checksyntax#debug
                    echo
                    echom printf('CheckSyntax: Processing %s (%s items)', self.name, len(list))
                endif
                if jobs == 0
                    " let bg = self.bg
                    let bg = 1
                    " let manually = self.manually
                    let manually = g:checksyntax#debug
                    call g:checksyntax#issues.Display(manually, bg)
                endif
            endif
        finally
            let &errorformat = errorformat
        endtry
    endif
endf


function! s:AsyncCommandHandler(make_def)
    " TLogVAR a:make_def
    let type = get(a:make_def, 'listtype', 'loc')
    let async_handler = {
                \ 'async_cmd': type == 'loc' ? 'lgetfile' : 'cgetfile',
                \ 'async_type': type,
                \ 'async_efm': get(a:make_def, 'efm', &errorformat),
                \ }
    call extend(async_handler, a:make_def)
    call extend(async_handler, s:async_handler, 'keep')
    " TLogVAR async_handler
    return asynccommand#tab_restore(async_handler)
endf


function! checksyntax#async#asynccommand#Run(cmd, make_def) "{{{3
    " TLogVAR a:cmd, a:make_def
    let async_handler = s:AsyncCommandHandler(a:make_def)
    " TLogVAR async_handler
    call asynccommand#run(a:cmd, async_handler)
    return 1
endf

