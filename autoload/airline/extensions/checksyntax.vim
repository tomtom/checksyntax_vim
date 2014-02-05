if !exists(':CheckSyntax')
    finish
endif


function! airline#extensions#checksyntax#get_msg()
    let errors = checksyntax#Status()
    if !empty(errors)
        return errors.(g:airline_symbols.space)
    endif
    return ''
endf


let s:spc = g:airline_symbols.space


function! airline#extensions#checksyntax#apply(...)
    let w:airline_section_c = get(w:, 'airline_section_c', g:airline_section_c)
    let w:airline_section_c .= s:spc . g:airline_left_alt_sep . s:spc . '%{airline#extensions#checksyntax#get_msg()}'
endf


function! airline#extensions#checksyntax#init(ext)
    call airline#parts#define_function('checksyntax', 'airline#extensions#checksyntax#get_msg')
  "  call airline#parts#define_raw('checksyntax', '%{airline#extensions#checksyntax#get_msg()}')
   call a:ext.add_statusline_func('airline#extensions#checksyntax#apply')
endf


" vi: ft=vim:tw=72:ts=4
