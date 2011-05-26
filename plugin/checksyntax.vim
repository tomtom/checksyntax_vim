" checksyntax.vim -- Check syntax when saving a file (php, ruby, tex ...)
" @Author:      Tom Link (micathom AT gmail com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     04-Mai-2005.
" @Last Change: 2011-05-26.
" GetLatestVimScripts: 1431 0 :AutoInstall: checksyntax.vim
" @Revision:    396

if exists('g:loaded_checksyntax')
    finish
endif
let g:loaded_checksyntax = 103


" @TPluginInclude
if !exists('g:checksyntax_auto')
    " If non-null, enable automatic syntax checks after saving a file.
    let g:checksyntax_auto = 1
endif


" @TPluginInclude
augroup CheckSyntax
    autocmd!
    if g:checksyntax_auto
        autocmd CheckSyntax BufWritePost * call checksyntax#Check(0)
    endif
augroup END


" :display: CheckSyntax[!] [NAME]
" Check the current buffer's syntax (type defaults to &filetype).
" Or use NAME instead of &filetype.
"
" With the bang !, use the alternative syntax checker (see 
" |g:checksyntax|).
command! -bang -nargs=? CheckSyntax call checksyntax#Check(1, "<bang>", <f-args>)


" @TPluginInclude
if !hasmapto(':CheckSyntax') && empty(maparg('<F5>', 'n'))
    noremap <F5> :CheckSyntax<cr>
    inoremap <F5> <c-o>:CheckSyntax<cr>
endif

