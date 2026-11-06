function! Test_x_puts_hyphen()
    call Given(g:even, 6, 4)
    call Keys('x')
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|---1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 4)
endfunction

function! Test_s_puts_hyphen_and_replaces()
    call Given(g:even, 6, 4)
    call Keys("s5\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-5-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 4)
endfunction

function! Test_x_off_string_line_deletes()
    call Given(g:even, 9, 1)
    call Keys('x')
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-0-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        yrics
    END
    call ExpectBuffer(l:want)
endfunction

function! Test_X_clears_column_and_chord_name()
    call Given(g:even, 6, 4)
    call Keys('X')
    let l:want =<< trim END
        []
               C7  G
        e|---1-2-3|4-5-6-7-|
        B|---1-2-3|4-5-6-7-|
        G|---1-2-3|4-5-6-7-|
        D|---1-2-3|4-5-6-7-|
        A|---1-2-3|4-5-6-7-|
        E|---1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 5)
endfunction

function! Test_X_with_count()
    call Given(g:even, 6, 4)
    call Keys('3X')
    let l:want =<< trim END
        []
               C7  G
        e|-----2-3|4-5-6-7-|
        B|-----2-3|4-5-6-7-|
        G|-----2-3|4-5-6-7-|
        D|-----2-3|4-5-6-7-|
        A|-----2-3|4-5-6-7-|
        E|-----2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 7)
endfunction

function! Test_X_keeps_name_and_opening_bar()
    call Given(g:even, 6, 2)
    call Keys('X')
    call ExpectBuffer(g:even)
    call ExpectCursor(6, 2)
endfunction

function! Test_X_pads_short_strings()
    call Given(g:uneven, 4, 12)
    call Keys('X')
    let l:want =<< trim END
        []

        e|--0--|--1-
        B|--0--|--3--|
        G|--0--|--2--|
        D|--2--|--0--|
        A|--2--|-----|
        E|--0--|-----|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(4, 13)
endfunction

function! Test_X_from_low_string_under_ignorecase()
    set ignorecase
    call Given(g:even, 8, 4)
    call Keys('X')
    let l:want =<< trim END
        []
               C7  G
        e|---1-2-3|4-5-6-7-|
        B|---1-2-3|4-5-6-7-|
        G|---1-2-3|4-5-6-7-|
        D|---1-2-3|4-5-6-7-|
        A|---1-2-3|4-5-6-7-|
        E|---1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(8, 5)
endfunction

function! Test_d_with_count_and_motion()
    call Given(g:even, 6, 4)
    call Keys('3dl')
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-----2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
endfunction

function! Test_c_puts_hyphens_and_replaces()
    call Given(g:even, 6, 4)
    call Keys("c3l9\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-9---2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 4)
endfunction

function! Test_C_puts_hyphens_to_end_and_replaces()
    call Given(g:even, 6, 12)
    call Keys("C9\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-0-1-2-3|9-------|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 12)
endfunction

function! Test_C_keeps_bars()
    call Given(g:even, 6, 6)
    call Keys("C9\<Esc>")
    let l:want = copy(g:even)
    let l:want[5] = 'D|-0-9----|--------|'
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 6)
endfunction

function! Test_C_on_string_name_starts_at_column_3()
    call Given(g:even, 6, 1)
    call Keys("C9\<Esc>")
    let l:want = copy(g:even)
    let l:want[5] = 'D|9-------|--------|'
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 3)
endfunction

function! Test_C_with_count()
    call Given(g:even, 6, 12)
    call Keys("2C9\<Esc>")
    let l:want = copy(g:even)
    let l:want[5] = 'D|-0-1-2-3|9-------|'
    let l:want[6] = 'A|--------|--------|'
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 12)
endfunction

function! Test_d_off_string_line_deletes()
    call Given(g:even, 9, 1)
    call Keys('dw')
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-0-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|

    END
    call ExpectBuffer(l:want)
endfunction

function! Test_visual_d_on_part_of_staff_keeps_chord_name()
    call Given(g:even, 5, 4)
    call Keys("\<C-v>jd")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|---1-2-3|4-5-6-7-|
        D|---1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(5, 4)
endfunction

function! Test_V_d_clears_column_and_chord_name()
    call Given(g:even, 6, 4)
    call Keys("\<S-v>d")
    let l:want =<< trim END
        []
               C7  G
        e|---1-2-3|4-5-6-7-|
        B|---1-2-3|4-5-6-7-|
        G|---1-2-3|4-5-6-7-|
        D|---1-2-3|4-5-6-7-|
        A|---1-2-3|4-5-6-7-|
        E|---1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(3, 4)
endfunction

function! Test_V_c_clears_column_and_replaces()
    call Given(g:even, 6, 4)
    call Keys("\<S-v>c5\<Esc>")
    let l:want =<< trim END
        []
               C7  G
        e|-5-1-2-3|4-5-6-7-|
        B|---1-2-3|4-5-6-7-|
        G|---1-2-3|4-5-6-7-|
        D|---1-2-3|4-5-6-7-|
        A|---1-2-3|4-5-6-7-|
        E|---1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(3, 4)
endfunction

function! Test_linewise_d_clears_notes_and_keeps_bars()
    call Given(g:even, 4, 4)
    call Keys('dj')
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|--------|--------|
        G|--------|--------|
        D|-0-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(4, 3)
endfunction

function! Test_linewise_d_keeps_lines_below_the_staff()
    call Given(g:even, 8, 4)
    call Keys('dj')
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-0-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|--------|--------|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(8, 3)
endfunction

function! Test_d_paragraph_clears_only_strings()
    call Given(g:even, 4, 4)
    call Keys('dap')
    let l:want =<< trim END
        []
           Am  C7  G
        e|--------|--------|
        B|--------|--------|
        G|--------|--------|
        D|--------|--------|
        A|--------|--------|
        E|--------|--------|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(3, 3)
endfunction

function! Test_dd_clears_the_string()
    call Given(g:even, 6, 6)
    call Keys('dd')
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|--------|--------|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 3)
endfunction

function! Test_dd_with_count()
    call Given(g:even, 5, 6)
    call Keys('2dd')
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|--------|--------|
        D|--------|--------|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(5, 3)
endfunction

function! Test_linewise_c_replaces_from_column_3()
    call Given(g:even, 4, 4)
    call Keys("cj9\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|9-------|--------|
        G|--------|--------|
        D|-0-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(4, 3)
endfunction

function! Test_cc_replaces_the_string()
    call Given(g:even, 6, 4)
    call Keys("cc9\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|9-------|--------|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 3)
endfunction

function! Test_d_motion_keeps_bars()
    call Given(g:even, 4, 4)
    call Keys("d/5\<CR>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|--------|--5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-0-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(4, 4)
endfunction

function! Test_d_motion_across_strings()
    call Given(g:even, 4, 14)
    call Keys("d/1\<CR>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-------|
        G|---1-2-3|4-5-6-7-|
        D|-0-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(4, 14)
endfunction

function! Test_x_keeps_string_name()
    call Given(g:even, 6, 1)
    call Keys('x')
    call ExpectBuffer(g:even)
    call ExpectCursor(6, 1)
endfunction

function! Test_x_keeps_opening_bar()
    call Given(g:even, 6, 2)
    call Keys('x')
    call ExpectBuffer(g:even)
    call ExpectCursor(6, 2)
endfunction

function! Test_s_keeps_string_name()
    call Given(g:even, 6, 1)
    call Keys("s5\<Esc>")
    call ExpectBuffer(g:even)
    call ExpectCursor(6, 1)
endfunction

function! Test_s_keeps_opening_bar()
    call Given(g:even, 6, 2)
    call Keys("s5\<Esc>")
    call ExpectBuffer(g:even)
    call ExpectCursor(6, 2)
endfunction
