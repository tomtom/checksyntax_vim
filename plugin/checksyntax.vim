" checksyntax.vim -- Check syntax when saving a file (php, ruby, tex ...)
" @Author:      Tom Link (micathom AT gmail com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     04-Mai-2005.
" @Last Change: 2010-04-23.
" @Revision:    380

if exists('g:checksyntax')
    finish
endif
let g:checksyntax = 6


" @TPluginInclude
if !exists('g:checksyntax_auto')
    let g:checksyntax_auto = 1
endif


" @TPluginInclude
augroup CheckSyntax
    autocmd!
    if g:checksyntax_auto
        autocmd CheckSyntax BufWritePost * call checksyntax#Check(0)
    endif
augroup END


command! -bang -nargs=? CheckSyntax call checksyntax#Check(1, "<bang>", <f-args>)


" @TPluginInclude
if !hasmapto(':CheckSyntax')
    noremap <F5> :CheckSyntax<cr>
    inoremap <F5> <c-o>:CheckSyntax<cr>
endif


finish
0.2
php specific

0.3
generalized plugin; modes; support for ruby, phpp, tex (chktex)

0.4
use vim compilers if available (e.g., tidy, xmllint ...); makeprg was 
restored in the wrong window

0.5
- Support for jsl (javascript lint).
- Support for jlint.
- Don't automatically check php files if eclim is installed.
- Allow auto_* parameters to be buffer local.
- FIX: Unlet current_compiler, use g:current_compiler
- FIX: garbled screen: use redraw! (thanks to Vincent de Lau)
- Support for lua (thanks to norman)

0.6
- checksyntax_compiler_{&ft} & checksyntax_cmd_{&ft} variables can be 
buffer local

