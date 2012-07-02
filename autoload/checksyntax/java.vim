" java.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-07-02.
" @Last Change: 2012-07-02.
" @Revision:    1


if !exists('g:checksyntax.java')
    if executable('jlint')
        let g:checksyntax['java'] = {
                    \ 'exec': 'call checksyntax#Jlint()',
                    \ 'alt': 'javaCheckstyle'
                    \ }

        " :nodoc:
        function! checksyntax#Jlint() "{{{3
            let filename = expand('%:r') .'.class'
            " TLogVAR filename
            " echom '! jlint -done '. shellescape(filename)
            exec '! jlint -done '. shellescape(filename)
        endf
    endif
endif

if !exists('g:checksyntax.javaCheckstyle')
    if executable('checkstyle')
        let g:checksyntax['javaCheckstyle'] = {
                    \ 'compiler': 'checkstyle',
                    \ }
    endif
endif


