" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    8


if index(g:checksyntax#syntax_allow_tabs, &filetype) == -1

    " Tabs
    syn match VimCheckSyntaxTabs /\t\+/ containedin=ALL

    hi def link VimCheckSyntaxTabs CheckSyntaxWarning

endif

