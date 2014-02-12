" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    23


call checksyntax#AddChecker('xml?',
            \   {
            \     'compiler': 'xmllint',
            \     'compiler_args': '%',
            \     'convert_filename': checksyntax#MaybeUseCygpath('xmllint'),
            \   }
            \ )


