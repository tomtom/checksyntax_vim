" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    10

syn match VimWarningIfEqual /\<if\>\%([^|'"]\|'.\{-}'\|".\{-}"\)\{-}[^=!<>]=[^=~<>#?]/ containedin=ALL
hi def link VimWarningIfEqual SpellBad

" syn match VimWarningBufNr /^.\{-}bufnr('\.')/ containedin=ALL
syn match VimWarningBufNr /\<\(bufnr('\.')\|bufnr()\|winnr('[.%]')\)/ containedin=ALL
hi def link VimWarningBufNr SpellBad

syn match VimWarningElseIf /\<else\>\s\+\<if\>/ containedin=ALL
hi def link VimWarningElseIf SpellRare

