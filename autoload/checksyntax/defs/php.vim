" php.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-07-02.
" @Last Change: 2012-08-15.
" @Revision:    6


if executable('php')

    if !exists('g:checksyntax.php')
        let g:checksyntax['php'] = {
                    \ 'auto': 1,
                    \ 'cmd': 'php -l -d display_errors=0 -d error_log= -d error_reporting=E_PARSE',
                    \ 'efm': '%*[^:]: %m in %f on line %l',
                    \ 'alt': 'phpp'
                    \ }
    endif


    if !exists('g:checksyntax.phpp')
        let g:checksyntax['phpp'] = {
                    \ 'cmd': 'php -f',
                    \ 'efm': g:checksyntax.php.efm,
                    \ }
    endif

endif

if exists('g:checksyntax.php')
    autocmd CheckSyntax BufReadPost *.php if exists(':EclimValidate') && !empty(eclim#project#util#GetCurrentProjectName()) | let g:checksyntax.php.auto = 0 | endif
endif

