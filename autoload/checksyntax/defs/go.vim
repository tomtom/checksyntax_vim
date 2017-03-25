" @Author:      Thomas Frowein (mailto:tfrowein AT gmx de?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    5


call checksyntax#AddChecker('go?',
            \ {
            \ 'cmd': 'go build %',
            \ 'listtype': 'qfl'},
            \ {
            \ 'cmd': 'gometalinter',
            \ 'cmd_args': '',
            \ 'efm': '%f:%l:%c:%m',
            \ 'listtype': 'qfl'}
            \ )

