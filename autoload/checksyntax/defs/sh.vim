" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    7

if &shell =~ '\<bash\>'
    call checksyntax#AddChecker('sh?',
                \ {
                \ 'cmd': 'bash -n',
                \ 'efm': '%f: %\\w%\\+ %l: %m',
                \ 'convert_filename': checksyntax#MaybeUseCygpath('bash'),
                \ }
                \ )
endif

