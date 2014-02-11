" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    4


call checksyntax#Require('c')
call checksyntax#AddChecker('cpp?', checksyntax#GetChecker('c'))

