function! Test_yy_yanks_staff_column()
    call Given(g:even, 5, 4)
    call Keys('"ayy')
    call assert_equal(['0', '0', '0', '0', '0', '0'], getreg('a', 1, 1))
    call assert_equal("\<C-v>1", getregtype('a'))
    call ExpectBuffer(g:even)
    call ExpectCursor(5, 4)
endfunction

function! Test_yy_off_string_line_yanks_line()
    call Given(g:even, 9, 1)
    call Keys('"ayy')
    call assert_equal(['lyrics'], getreg('a', 1, 1))
    call assert_equal('V', getregtype('a'))
endfunction

function! Test_V_selects_staff_column()
    call Given(g:even, 6, 6)
    call Keys("\<S-v>\"by")
    call assert_equal(['1', '1', '1', '1', '1', '1'], getreg('b', 1, 1))
    call assert_equal("\<C-v>1", getregtype('b'))
endfunction
