" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    39


" Assignment in |:if| expression.
syn match VimCheckSyntaxError /\%(^\||\)\s*\<if\>\%([^|'"]\|'.\{-}'\|".\{-}"\)\{-}[^=!<>]=[^=~<>#?]/ containedin=vimFuncList

" Wrong arguments for |bufnr()| or |winnr()|.
syn match VimCheckSyntaxError /\<\(bufnr('\.')\|bufnr()\|winnr('[.%]')\)/ containedin=vimFuncBodyList

" a: variables as function arguments
syn match VimCheckSyntaxError /\%(^\||\)\s*fu\%[nction]!\?\s[^(]\+(.\{-}a:/ containedin=vimFuncList

" `else if` instead of |:elseif|
syn match VimCheckSyntaxError /\<else\>\s\+\<if\?\>/ containedin=vimFuncList

hi def link VimCheckSyntaxError SpellBad
hi def link VimCheckSyntaxWarning SpellRare

