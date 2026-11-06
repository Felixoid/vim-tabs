function! Test_leader_bar_draws_bar()
    call Given(g:even, 6, 6)
    call Keys('-|')
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-|-2-3|4-5-6-7-|
        B|-0-|-2-3|4-5-6-7-|
        G|-0-|-2-3|4-5-6-7-|
        D|-0-|-2-3|4-5-6-7-|
        A|-0-|-2-3|4-5-6-7-|
        E|-0-|-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 6)
endfunction

function! Test_leader_bar_clears_chord_name()
    call Given(g:even, 6, 8)
    call Keys('-|')
    let l:want =<< trim END
        []
           Am      G
        e|-0-1-|-3|4-5-6-7-|
        B|-0-1-|-3|4-5-6-7-|
        G|-0-1-|-3|4-5-6-7-|
        D|-0-1-|-3|4-5-6-7-|
        A|-0-1-|-3|4-5-6-7-|
        E|-0-1-|-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 8)
endfunction

function! Test_leader_bar_pads_short_strings()
    call Given(g:uneven, 4, 12)
    call Keys('-|')
    let l:want =<< trim END
        []

        e|--0--|--1|
        B|--0--|--3|-|
        G|--0--|--2|-|
        D|--2--|--0|-|
        A|--2--|---|-|
        E|--0--|---|-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(4, 12)
endfunction

function! Test_leader_bar_off_string_line_does_nothing()
    call Given(g:even, 9, 3)
    call Keys('-|')
    call ExpectBuffer(g:even)
    call ExpectCursor(9, 3)
endfunction

function! Test_insert_bar_draws_bar_and_moves_on()
    call Given(g:even, 6, 5)
    call Keys("i|7\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0|1-2-3|4-5-6-7-|
        B|-0|1-2-3|4-5-6-7-|
        G|-0|1-2-3|4-5-6-7-|
        D|-0|7-2-3|4-5-6-7-|
        A|-0|1-2-3|4-5-6-7-|
        E|-0|1-2-3|4-5-6-7-|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(6, 6)
endfunction

function! Test_insert_bar_off_string_line_is_literal()
    call Given(g:even, 9, 6)
    call Keys("i|\<Esc>")
    let l:want =<< trim END
        []
           Am  C7  G
        e|-0-1-2-3|4-5-6-7-|
        B|-0-1-2-3|4-5-6-7-|
        G|-0-1-2-3|4-5-6-7-|
        D|-0-1-2-3|4-5-6-7-|
        A|-0-1-2-3|4-5-6-7-|
        E|-0-1-2-3|4-5-6-7-|
        lyric|s
    END
    call ExpectBuffer(l:want)
endfunction
