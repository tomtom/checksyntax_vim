" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    97

" :doc:
"                                                     *checksyntax_enable_syntax-vim*
" Simple syntax checks for the vim 'filetype'~
"
" Setting |g:checksyntax_enable_syntax| enables the following checks:
"
" - Assignment in |:if| expression
" - `else if` instead of |:elseif|
" - Propably wrong arguments for |bufnr()| or |winnr()|
" - Don't ignore/simplify the return value of |exists()| for cmdnames
" - Calls like exists('fnname()')
" - Don't write exists('foo'). If it's a variable, make the scope explicit 
"   (like `g:foo`). Otherwise it was an error anyway.
" - Variables with scope (|g:|, |l:|, |a:var| etc.) in function 
"   argument position


syn match VimCheckSyntaxError /\%(^\||\)\s*\zs\<if\>\%('[^']*'\|"[^"]*"\|[^|]\)\{-}[^=!<>]=[^=~<>#?]/ containedin=ALLBUT,vimLineComment,vimString

syn match VimCheckSyntaxError /\%(^\||\)\s*\zs\<\(els\|else \)if\>/ containedin=ALLBUT,vimLineComment,vimString

syn match VimCheckSyntaxError /\<\(bufnr(\%(["']\.["']\)\?)\|winnr(['"][.%]['"])\)/ containedin=ALLBUT,vimLineComment,vimString

syn match VimCheckSyntaxError /\<exists(\(["']\)[^'"]*()\1)/ containedin=ALLBUT,vimLineComment,vimString

syn match VimCheckSyntaxWarning /\<exists(\(["']\):.\{-}\1)\s*$/ containedin=ALLBUT,vimLineComment,vimString

" syn match VimCheckSyntaxWarning /\<exists(\(["']\)\%(\w:\)\@![^*&#+$:].\{-}\1)/ containedin=ALLBUT,vimLineComment,vimString

syn match VimCheckSyntaxError /\%(^\||\)\s*fu\%[nction]!\?\s[^(]\+([^)]\{-}\<\w:/ containedin=ALLBUT,vimLineComment,vimString

syn match VimCheckSyntaxError /\<else\>\s\+\k\+/ containedin=ALLBUT,vimLineComment,vimString

" Prefer ==# or ==? etc.
syn match VimCheckSyntaxWarning /\s\zs[!=][=~]\ze\s*['"]/ containedin=ALLBUT,vimLineComment,vimString

" Prefer single quotes
" syn match VimCheckSyntaxWarning /"[^"]*"/ containedin=ALLBUT,vimLineComment,vimString,Constant,vimSynRegPat

hi def link VimCheckSyntaxError CheckSyntaxError
hi def link VimCheckSyntaxWarning CheckSyntaxWarning

