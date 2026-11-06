" The innermost syntax group at a position, '' for none.
function! s:Syn(lnum, col)
    return synIDattr(synID(a:lnum, a:col, 1), 'name')
endfunction

function! Test_syntax_string_line()
    call Given(['b|-0-|12-x-<7>|'], 1, 1)
    call assert_equal('tabName', s:Syn(1, 1))
    call assert_equal('tabBar', s:Syn(1, 2))
    call assert_equal('tabHyphen', s:Syn(1, 3))
    call assert_equal('tabFret', s:Syn(1, 4))
    call assert_equal('tabFret', s:Syn(1, 8))
    call assert_equal('tabMute', s:Syn(1, 10))
    call assert_equal('tabHarmonic', s:Syn(1, 12))
    call assert_equal('tabHarmonic', s:Syn(1, 13))
endfunction

function! Test_syntax_techniques()
    let l:line = 'e|5/7\5h7p5b7r5t9~|'
    call Given([l:line], 1, 1)
    for l:col in range(1, len(l:line))
        if l:line[l:col - 1] =~# '[/\\hpbrt~]'
            call assert_equal('tabTechnique', s:Syn(1, l:col), 'column ' . l:col)
        endif
    endfor
endfunction

function! Test_syntax_header()
    call Given(['[Song]'], 1, 1)
    call assert_equal('tabHeader', s:Syn(1, 1))
endfunction

function! Test_syntax_chord_names()
    let l:chords = ['Am', 'C7', 'G', 'Am7', 'Emaj7', 'Amin', 'CM7', 'F#m7b5', 'Bb', 'Dsus4', 'Cadd9', 'C/G', 'E7#9', 'C6/9', 'Gm/Bb', 'Ddim', 'Faug']
    call Given([join(l:chords, ' '), 'e|---|'], 1, 1)
    let l:col = 1
    for l:chord in l:chords
        call assert_equal('tabChord', s:Syn(1, l:col), l:chord)
        call assert_equal('tabChord', s:Syn(1, l:col + len(l:chord) - 1), l:chord)
        let l:col += len(l:chord) + 1
    endfor
endfunction

function! Test_syntax_chords_above_staff()
    call Given(g:even, 2, 1)
    call assert_notequal('tabChord', s:Syn(2, 1))
    call assert_equal('tabChord', s:Syn(2, 4))
    call assert_equal('tabChord', s:Syn(2, 8))
endfunction

function! Test_syntax_chords_above_lyrics_stay_plain()
    call Given(['Am  C', 'lyrics'], 1, 1)
    call assert_equal('', s:Syn(1, 1))
endfunction

function! Test_syntax_mixed_line_above_staff_stays_plain()
    call Given(['Am and C', 'e|---|'], 1, 1)
    call assert_equal('', s:Syn(1, 1))
endfunction

function! Test_syntax_leaves_lyrics_plain()
    call Given(['A well-known day | 1/2 3h4'], 1, 1)
    for l:col in range(1, len(getline(1)))
        call assert_equal('', s:Syn(1, l:col), 'column ' . l:col)
    endfor
endfunction
