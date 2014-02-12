" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    10


if !exists('g:checksyntax#defs#ruby#interpreter')
    let g:checksyntax#defs#ruby#interpreter = system('ruby --version')   "{{{2
endif


let s:def = {
            \     'prepare': 'compiler ruby',
            \     'cmd': 'ruby -c',
            \ }

if g:checksyntax#defs#ruby#interpreter =~ '\<jruby'
    let s:def.efm = 'SyntaxError in %f:%l:%m'
else
    let s:def.convert_filename = checksyntax#MaybeUseCygpath('xmllint')
endif

call checksyntax#AddChecker('ruby?', s:def)

unlet s:def

