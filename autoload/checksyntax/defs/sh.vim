" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    8

if &shell =~ '\<bash\>'
    call checksyntax#AddChecker('sh?',
                \ {
                \ 'cmd': 'shellcheck -f gcc',
                \ 'efm': '%f:%l:%c: %m',
                \ 'convert_filename': checksyntax#MaybeUseCygpath('bash'),
                \ },
                \ {
                \ 'cmd': 'bash -n',
                \ 'efm': '%f: %\\w%\\+ %l: %m',
                \ 'convert_filename': checksyntax#MaybeUseCygpath('bash'),
                \ }
                \ )
endif

