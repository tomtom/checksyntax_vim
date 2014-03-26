" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    3


" Trailing space
syn match VimCheckSyntaxTrailingWhitespace /\s\+\%(\%#\)\@!$/ containedin=ALL

hi def link VimCheckSyntaxTrailingWhitespace CheckSyntaxWarning

