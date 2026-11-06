function! Test_i_on_hyphen_replaces()
    call Given(g:even, 6, 5)
    call Keys("i7\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-071-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 5)
endfunction

function! Test_tab_moves_to_next_string()
    call Given(g:even, 6, 5)
    call Keys("i7\<Tab>5\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-071-2-3|4-5-6-7-|
        A|-0-5-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(7, 6)
endfunction

function! Test_shift_tab_moves_to_previous_string()
    call Given(g:even, 6, 5)
    call Keys("i7\<S-Tab>5\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-5-2-3|4-5-6-7-|
        D|-071-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(5, 6)
endfunction

function! Test_a_replaces_after_cursor()
    call Given(g:even, 6, 5)
    call Keys("a7\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-0-7-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 6)
endfunction

function! Test_A_replaces_after_next_bar()
    call Given(g:even, 6, 5)
    call Keys("A7\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-0-1-2-3|7-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 12)
endfunction

function! Test_A_on_unclosed_string_appends()
    call Given(g:uneven, 3, 9)
    call Keys("A79\<Esc>")
    let l:want =<< trim END
        []

        e|--0--|--179
        B|--0--|--3--|
        G|--0--|--2--|
        D|--2--|--0--|
        A|--2--|-----|
        E|--0--|-----|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(3, 13)
endfunction

function! Test_typing_past_the_end_extends_the_staff()
    call Given(g:even, 6, 19)
    call Keys("A79\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|--
        B|-0-1-2-3|4-5-6-7-|--
        G|-0-1-2-3|4-5-6-7-|--
        D|-0-1-2-3|4-5-6-7-|79
        A|-0-1-2-3|4-5-6-7-|--
        E|-0-1-2-3|4-5-6-7-|--
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 22)
endfunction

function! Test_I_replaces_after_previous_bar()
    call Given(g:even, 6, 14)
    call Keys("I9\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-0-1-2-3|9-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 12)
endfunction

function! Test_space_types_hyphen()
    call Given(g:even, 6, 3)
    call Keys("a\<Space>\<Esc>")
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

function! Test_off_string_line_insert_is_plain()
    call Given(g:even, 9, 1)
    call Keys("iX\<Space>\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-0-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        X lyrics
    END
    call ExpectBuffer(l:want)
endfunction

" Known bugs.

function! XFail_i_must_replace_digit()
    call Given(g:even, 6, 4)
    call Keys("i7\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-7-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 4)
endfunction

" In columns 1 and 2, i starts at column 3, like I starts after the bar.
function! XFail_i_must_keep_string_name()
    call Given(g:even, 6, 1)
    call Keys("i7\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|70-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 3)
endfunction
