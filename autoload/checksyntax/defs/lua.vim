" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    4


call checksyntax#AddChecker('lua?',
            \ {
            \ 'if_executable': 'luac',
            \ 'cmd': 'luac -p',
            \ 'efm': 'luac\:\ %f:%l:\ %m'
            \ }
            \ )

