" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    13


if !exists('g:checksyntax#pmd#cmd')
    " The command to run pmd.
    let g:checksyntax#pmd#cmd = ''   "{{{2
endif


if !exists('g:checksyntax#pmd#args')
    let g:checksyntax#pmd#args = '-f text'   "{{{2
endif


function! checksyntax#pmd#Cmd(language, args, rulesets) "{{{3
    if empty(g:checksyntax#pmd#cmd)
        return ''
    else
        let args = [g:checksyntax#pmd#args, a:args, '-l', a:language]
        if !exists('b:checksyntax_project_dir')
            if exists('b:project_dir')
                let b:checksyntax_project_dir = b:project_dir
            else
                let b:checksyntax_project_dir = expand('%:h')
            endif
        endif
        call add(args, '-d '. shellescape(b:checksyntax_project_dir))
        let rulesets = join(map(copy(a:rulesets), 'a:language ."-". v:val'), ',')
        let args += ['-R', rulesets]
        return printf("%s %s",
                    \ g:checksyntax#pmd#cmd,
                    \ join(args))
    endif
endf

