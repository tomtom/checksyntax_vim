" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    205

" :doc:
" Syntax checkers for Rmd:
" - See r

call checksyntax#Require('r')
call checksyntax#AddChecker('rmd?', checksyntax#GetChecker('r', '\<lintr$'))

