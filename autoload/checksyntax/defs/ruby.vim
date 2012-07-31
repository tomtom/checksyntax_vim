" ruby.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-07-02.
" @Last Change: 2012-07-08.
" @Revision:    2


if !exists('g:checksyntax.ruby')
    let ruby_interpreter = system('ruby --version')
    if match(ruby_interpreter, 'jruby') == -1
      let g:checksyntax['ruby'] = {
            \ 'prepare': 'compiler ruby',
            \ 'cmd': 'ruby -c',
            \ }
    else
      let g:checksyntax['ruby'] = {
            \ 'prepare': 'compiler ruby',
            \ 'efm': 'SyntaxError in %f:%l:%m',
            \ 'cmd': 'ruby -c',
            \ }

    endif
endif


