function! s:Staff(first, length)
    let l:staff = map(['e', 'B', 'G', 'D', 'A', 'E'], {_, name -> name . '|' . repeat('-', a:length) . '|'})
    let l:staff[0] = 'e|' . a:first . l:staff[0][2 + strlen(a:first):]
    return l:staff
endfunction

function! Test_leader_cr_on_staff_adds_staff_below_paragraph()
    call Given(g:even, 6, 5)
    call Keys("4-\<CR>7\<Esc>")
    call ExpectBuffer(g:even + ['', ''] + s:Staff('7', 4))
    call ExpectCursor(12, 3)
endfunction

function! Test_leader_cr_stops_at_blank_line()
    call Given(g:blank + ['', 'next'], 4, 5)
    call Keys("2-\<CR>9\<Esc>")
    call ExpectBuffer(g:blank + ['', ''] + s:Staff('9', 2) + ['', '', 'next'])
    call ExpectCursor(11, 3)
endfunction

function! Test_leader_cr_without_count_is_60_wide()
    call Given(g:blank, 3, 5)
    call Keys("-\<CR>")
    call assert_equal(g:blank + ['', ''] + s:Staff('', 60), getline(1, '$'))
endfunction

function! Test_leader_cr_off_staff_adds_staff_below_line()
    call Given(g:uneven, 1, 1)
    call Keys("2-\<CR>9\<Esc>")
    call ExpectBuffer(['[]', '', ''] + s:Staff('9', 2) + ['', ''] + g:uneven[2:])
    call ExpectCursor(4, 3)
endfunction

function! Test_leader_cr_counts_existing_blank_lines()
    call Given(g:uneven, 2, 1)
    call Keys("2-\<CR>9\<Esc>")
    call ExpectBuffer(g:uneven[:1] + [''] + s:Staff('9', 2) + ['', ''] + g:uneven[2:])
    call ExpectCursor(4, 3)
endfunction

function! Test_leader_cr_adds_no_blank_lines_when_enough()
    call Given(['[]', '', '', '', 'text'], 3, 1)
    call Keys("2-\<CR>9\<Esc>")
    call ExpectBuffer(['[]', '', ''] + s:Staff('9', 2) + ['', '', 'text'])
    call ExpectCursor(4, 3)
endfunction

" The staff is found by its string lines, not by the e| name: these name the
" high string E and the low one e.
function! Test_staff_with_E_on_top()
    let l:tab =<< trim END
        [Part I]
        E||--0------0---------|
        B||--0---0--0---------|
        G||--2---2--2---------|
        D||--2------2---------|
        A||--0------0---------|
        e||-------------------|

        E|--0------0------------|
        B|--4------4---------6--|
        G|--2---2--2------------|
        D|--1------1------------|
        A|--0------0------------|
        e|----------------------|
    END
    call Given(l:tab, 9, 10)
    call Keys('-|')
    let l:want =<< trim END
        [Part I]
        E||--0------0---------|
        B||--0---0--0---------|
        G||--2---2--2---------|
        D||--2------2---------|
        A||--0------0---------|
        e||-------------------|

        E|--0----|-0------------|
        B|--4----|-4---------6--|
        G|--2---2|-2------------|
        D|--1----|-1------------|
        A|--0----|-0------------|
        e|-------|--------------|
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(9, 10)
endfunction
