" Smoke test for Vims too old for test/run.vim:
" vim -Nu NONE -i NONE -es -S test/smoke.vim
" Uses :normal, which runs mappings on any Vim, and writes test/out.log.

let s:root = expand('<sfile>:p:h:h')
execute 'set rtp^=' . fnameescape(s:root)
filetype plugin on

let s:errors = []

function! s:Expect(name, want, have)
    if a:want !=# a:have
        call add(s:errors, 'FAIL  ' . a:name . ': expected ' . string(a:want) . ', got ' . string(a:have))
    endif
endfunction

function! s:Staff(width)
    return map(['e', 'B', 'G', 'D', 'A', 'E'], 'v:val . "|" . repeat("-", a:width) . "|"')
endfunction

let v:errmsg = ''
execute 'edit' fnameescape(tempname() . '.tab')
call s:Expect('new tab', ['[]', ''] + s:Staff(60) + [''], getline(1, '$'))

" Narrow the staff to keep the expected lines short.
silent 3,8delete _
call append(2, s:Staff(8))

call cursor(3, 4)
normal -Am
call s:Expect('chord', ['   Am', 'e|-0------|', 'B|-1------|'], getline(2, 4))

call cursor(4, 4)
normal x
call s:Expect('x', 'B|--------|', getline(4))

call cursor(4, 6)
normal -|
call s:Expect('-|', ['e|-0-|----|', 'E|---|----|'], [getline(3), getline(8)])

call cursor(4, 4)
execute "normal i7\<CR>5\<Esc>"
call s:Expect('i<CR>', ['B|-7-|----|', 'G|-25|----|'], getline(4, 5))

call cursor(6, 5)
execute "normal C9\<Esc>"
call s:Expect('C', 'D|-29|----|', getline(6))

call cursor(6, 4)
execute "normal 4-\<CR>"
call s:Expect('-<CR>', ['', ''] + s:Staff(4) + [''], getline(9, '$'))

if exists('*maplist')
    set filetype=
    call s:Expect('set ft=', '', maparg('x', 'n'))
endif

call s:Expect('errors', '', v:errmsg)

let s:out = s:errors + [printf('smoke test on Vim %d, %d failed', v:version, len(s:errors))]
call writefile(s:out, s:root . '/test/out.log')
execute empty(s:errors) ? 'qall!' : 'cquit'
