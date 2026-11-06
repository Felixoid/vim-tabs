function! Test_chord_writes_name_and_frets()
    call Given(g:blank, 4, 5)
    call Keys('-Am')
    let l:want =<< trim END
        []
            Am
        e|--0------|
        B|--1------|
        G|--2------|
        D|--2------|
        A|--0------|
        E|---------|
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(4, 5)
endfunction

function! Test_chord_pads_short_strings()
    call Given(g:uneven, 4, 12)
    call Keys('-Dm')
    let l:want =<< trim END
        []
                   Dm
        e|--0--|--11--
        B|--0--|--33-|
        G|--0--|--22-|
        D|--2--|--00-|
        A|--2--|-----|
        E|--0--|-----|
        lyrics
    END
    call ExpectBuffer(l:want)
    call ExpectCursor(4, 12)
endfunction

function! Test_user_chords_extend_defaults()
    let g:Chords = {'X': ['9']}
    try
        call Given(g:blank, 3, 4)
        call Keys('-X')
        call cursor(3, 8)
        call Keys('-G')
    finally
        unlet g:Chords
    endtry
    let l:want =<< trim END
        []
           X   G
        e|-9---1---|
        B|-----0---|
        G|-----0---|
        D|-----0---|
        A|-----2---|
        E|-----3---|
    END
    call ExpectBuffer(l:want)
endfunction

function! Test_chord_ignores_non_string_lines()
    call Given(g:even, 9, 3)
    call Keys('-Am')
    call ExpectBuffer(g:even)
    call ExpectCursor(9, 3)
endfunction

" Known bugs.

function! XFail_chord_must_keep_virtualedit()
    set virtualedit=block
    call Given(g:blank, 4, 5)
    call Keys('-Am')
    call assert_equal('block', &virtualedit)
endfunction
