" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    12

call checksyntax#AddChecker('ruby?', {
            \ 'compiler': 'checksyntax/ruby_c'
            \ })

