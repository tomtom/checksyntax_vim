" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    10


let s:async_handler = {}


function s:async_handler.get(temp_file_name) dict
    if checksyntax#RemoveJob(self.job_id)
        " echom "DBG async_handler.get" self.name self.job_id
        let errorformat = &errorformat
        try
            " TLogVAR self.async_type, self.bufnr, bufnr('%')
            if self.async_type != 'loc' || self.bufnr == bufnr('%')
                " let all_issues = g:checksyntax#prototypes[self.async_type].Get()
                " TLogVAR len(all_issues)
                let &errorformat = self.async_efm
                " TLogVAR self.async_efm
                " TLogVAR self.async_cmd, a:temp_file_name
                exe self.async_cmd a:temp_file_name
                let list = checksyntax#GetList(self.name, self, self.async_type)
                " TLogVAR list
                if g:checksyntax#debug
                    echo
                    echom printf('CheckSyntax: Processing %s (%s items)', self.name, len(list))
                endif
                " TLogVAR self.name, len(list)
                if !empty(list)
                    let g:checksyntax#async_issues += list
                    " echom "DBG async_handler.get all_issues:" len(all_issues)
                endif
                if empty(g:checksyntax#async_pending)
                    " let bg = self.bg
                    let bg = 1
                    " let manually = self.manually
                    let manually = g:checksyntax#debug
                    let use_qfl = self.async_type == 'qfl'
                    " TLogVAR manually, bg, use_qfl
                    call checksyntax#HandleIssues(manually, use_qfl, bg, g:checksyntax#async_issues)
                endif
            endif
        finally
            let &errorformat = errorformat
        endtry
    endif
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


function! checksyntax#async#asynccommand#Run(cmd, make_def) "{{{3
    let async_handler = s:AsyncCommandHandler(a:make_def)
    " TLogVAR async_handler
    call asynccommand#run(a:cmd, async_handler)
    return 1
endf

