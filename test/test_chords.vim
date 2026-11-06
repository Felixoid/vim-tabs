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
        e|-9---3---|
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

function! Test_chord_keeps_virtualedit()
    call Given(g:blank, 4, 5)
    set virtualedit=block
    call Keys('-Am')
    call assert_equal('block', &virtualedit)
endfunction

function! Test_chord_keeps_window_local_virtualedit()
    if !has('patch-8.2.3227')
        call Skip("'virtualedit' is global only")
    endif
    call Given(g:blank, 4, 5)
    set virtualedit=block
    setlocal virtualedit=onemore
    call Keys('-Am')
    call assert_equal('onemore', &l:virtualedit)
    call assert_equal('block', &g:virtualedit)
    setlocal virtualedit=
endfunction
