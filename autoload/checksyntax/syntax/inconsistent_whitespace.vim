" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    12


if empty(&buftype)

    " Tabs
    syn match VimCheckSyntaxInconsistentWhitespace /\%( \t\|\t \)/ containedin=ALL

    hi def link VimCheckSyntaxInconsistentWhitespace CheckSyntaxWarning

endif

